# frozen_string_literal: true

require "roda"

require "base64"
require "json"

class Shrine
  module Plugins
    # The `download_endpoint` plugin provides a Rack endpoint for downloading
    # uploaded files from specified storages. This can be useful when files
    # from your storage isn't accessible over URL (e.g. database storages) or
    # if you want to authenticate your downloads. It requires the [Roda] gem.
    #
    #     # Gemfile
    #     gem "roda" # dependency of the download_endpoint plugin
    #
    # You can configure the plugin with the path prefix which the endpoint will
    # be mounted on.
    #
    #     plugin :download_endpoint, prefix: "attachments"
    #
    # The endpoint should then be mounted on the specified prefix:
    #
    #     # config.ru (Rack)
    #     map "/attachments" do
    #       run Shrine.download_endpoint
    #     end
    #
    #     # OR
    #
    #     # config/routes.rb (Rails)
    #     Rails.application.routes.draw do
    #       mount Shrine.download_endpoint => "/attachments"
    #     end
    #
    # Any uploaded file can be downloaded through this endpoint. When a file is
    # requested, its content will be efficiently streamed from the storage into
    # the response body.
    #
    # Links to the download endpoint are generated by calling
    # `UploadedFile#download_url` instead of the usual `UploadedFile#url`.
    #
    #     uploaded_file.download_url #=> "/attachments/eyJpZCI6ImFkdzlyeTM5ODJpandoYWla"
    #
    # Note that streaming the file through your app might impact the request
    # throughput of your app, depending on which web server is used. It's
    # recommended to either configure a CDN to serve these files:
    #
    #     plugin :download_endpoint, host: "http://abc123.cloudfront.net"
    #
    # or configure the endpoint to redirect to the direct file URL:
    #
    #     plugin :download_endpoint, redirect: true
    #     # or
    #     plugin :download_endpoint, redirect: -> (uploaded_file, request) do
    #       # return URL which the request will redirect to
    #     end
    #
    # Alternatively, you can stream files yourself from your controller using
    # the `rack_response` plugin, which this plugin uses internally.
    #
    # [Roda]: https://github.com/jeremyevans/roda
    module DownloadEndpoint
      def self.load_dependencies(uploader, opts = {})
        uploader.plugin :rack_response
      end

      # Accepts the following options:
      #
      # :prefix
      # :  The location where the download endpoint was mounted. If it was
      #    mounted at the root level, this should be set to nil.
      #
      # :host
      # :  The host that you want the download URLs to use (e.g. your app's domain
      #    name or a CDN). By default URLs are relative.
      #
      # :disposition
      # :  Can be set to "attachment" if you want that the user is always
      #    prompted to download the file when visiting the download URL.
      #    The default is "inline".
      #
      # :redirect
      # :  If set to `true`, requests will redirect to the direct file URL. If
      #    set to a proc object, the proc will called with the `UploadedFile`
      #    instance and the `Rack::Request` object, and is expected to return
      #    the URL to which the request will redirect to. Defaults to `false`,
      #    meaning that the file content will be served through the endpoint.
      def self.configure(uploader, opts = {})
        uploader.opts[:download_endpoint_storages] = opts.fetch(:storages, uploader.opts[:download_endpoint_storages])
        uploader.opts[:download_endpoint_prefix] = opts.fetch(:prefix, uploader.opts[:download_endpoint_prefix])
        uploader.opts[:download_endpoint_disposition] = opts.fetch(:disposition, uploader.opts.fetch(:download_endpoint_disposition, "inline"))
        uploader.opts[:download_endpoint_host] = opts.fetch(:host, uploader.opts[:download_endpoint_host])
        uploader.opts[:download_endpoint_redirect] = opts.fetch(:redirect, uploader.opts.fetch(:download_endpoint_redirect, false))

        Shrine.deprecation("The :storages download_endpoint option is deprecated, you should use UploadedFile#download_url for generating URLs to the download endpoint.") if uploader.opts[:download_endpoint_storages]

        uploader.assign_download_endpoint(App) unless uploader.const_defined?(:DownloadEndpoint)
      end

      module ClassMethods
        # Assigns the subclass a copy of the download endpoint class.
        def inherited(subclass)
          super
          subclass.assign_download_endpoint(@download_endpoint)
        end

        # Returns the Rack application that retrieves requested files.
        def download_endpoint
          @download_endpoint
        end

        # Assigns the subclassed endpoint as the `DownloadEndpoint` constant.
        def assign_download_endpoint(klass)
          endpoint_class = Class.new(klass)
          endpoint_class.opts[:shrine_class] = self
          endpoint_class.opts[:disposition]  = opts[:download_endpoint_disposition]
          endpoint_class.opts[:redirect]     = opts[:download_endpoint_redirect]

          @download_endpoint = endpoint_class

          const_set(:DownloadEndpoint, endpoint_class)
          deprecate_constant(:DownloadEndpoint) if RUBY_VERSION > "2.3"
        end

        def download_endpoint_serializer
          @download_endpoint_serializer ||= Serializer.new
        end
      end

      module FileMethods
        # Constructs the URL from the optional host, prefix, storage key and
        # uploaded file's id. For other uploaded files that aren't in the list
        # of storages it just returns their original URL.
        def url(**options)
          if download_storages && download_storages.include?(storage_key.to_sym)
            Shrine.deprecation("The :storages option for download_endpoint plugin is deprecated and will be obsolete in Shrine 3. Use UploadedFile#download_url instead.")
            download_url
          else
            super
          end
        end

        def download_url
          [download_host, *download_prefix, download_identifier].join("/")
        end

        private

        # Generates URL-safe identifier from data, filtering only a subset of
        # metadata that the endpoint needs to prevent the URL from being too
        # long.
        def download_identifier
          semantical_metadata = metadata.select { |name, _| %w[filename size mime_type].include?(name) }
          download_serializer.dump(data.merge("metadata" => semantical_metadata.sort.to_h))
        end

        def download_serializer
          shrine_class.download_endpoint_serializer
        end

        def download_host
          shrine_class.opts[:download_endpoint_host]
        end

        def download_prefix
          shrine_class.opts[:download_endpoint_prefix]
        end

        def download_storages
          shrine_class.opts[:download_endpoint_storages]
        end
      end

      # Routes incoming requests. It first asserts that the storage is existent
      # and allowed. Afterwards it proceeds with the file download using
      # streaming.
      class App < Roda
        route do |r|
          # handle legacy ":storage/:id" URLs
          r.on storage_names do |storage_name|
            r.get /(.*)/ do |id|
              data = { "id" => id, "storage" => storage_name, "metadata" => {} }
              serve_file(data)
            end
          end

          r.get /(.*)/ do |identifier|
            data = serializer.load(identifier)
            serve_file(data)
          end
        end

        private

        # Streams or redirects to the uploaded file.
        def serve_file(data)
          uploaded_file = get_uploaded_file(data)

          if redirect
            redirect_to_file(uploaded_file)
          else
            stream_file(uploaded_file)
          end
        end

        # Streams the uploaded file content.
        def stream_file(uploaded_file)
          range = env["HTTP_RANGE"]

          status, headers, body = uploaded_file.to_rack_response(disposition: disposition, range: range)
          headers["Cache-Control"] = "max-age=#{365*24*60*60}" # cache for a year

          request.halt [status, headers, body]
        end

        # Redirects to the uploaded file's direct URL or the specified URL proc.
        def redirect_to_file(uploaded_file)
          if redirect == true
            redirect_url = uploaded_file.url
          else
            redirect_url = redirect.call(uploaded_file, request)
          end

          request.redirect redirect_url
        end

        # Returns a Shrine::UploadedFile, or returns 404 if file doesn't exist.
        def get_uploaded_file(data)
          uploaded_file = shrine_class.uploaded_file(data)
          not_found! unless uploaded_file.exists?
          uploaded_file
        rescue Shrine::Error
          not_found!
        end

        def not_found!
          error!(404, "File Not Found")
        end

        # Halts the request with the error message.
        def error!(status, message)
          response.status = status
          response["Content-Type"] = "text/plain"
          response.write(message)
          request.halt
        end

        def storage_names
          shrine_class.storages.keys.map(&:to_s)
        end

        def serializer
          shrine_class.download_endpoint_serializer
        end

        def redirect
          opts[:redirect]
        end

        def disposition
          opts[:disposition]
        end

        def shrine_class
          opts[:shrine_class]
        end
      end

      class Serializer
        def dump(data)
          base64_encode(json_encode(data))
        end

        def load(data)
          json_decode(base64_decode(data))
        end

        private

        def json_encode(data)
          JSON.generate(data)
        end

        def base64_encode(data)
          Base64.urlsafe_encode64(data)
        end

        def base64_decode(data)
          Base64.urlsafe_decode64(data)
        end

        def json_decode(data)
          JSON.parse(data)
        end
      end
    end

    register_plugin(:download_endpoint, DownloadEndpoint)
  end
end
