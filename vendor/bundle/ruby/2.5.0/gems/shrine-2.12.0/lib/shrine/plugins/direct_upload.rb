# frozen_string_literal: true

Shrine.deprecation("The direct_upload plugin has been deprecated in favor of upload_endpoint and presign_endpoint plugins. The direct_upload plugin will be removed in Shrine 3.")

require "roda"
require "json"

class Shrine
  module Plugins
    # *[OBSOLETE] This plugin is obsolete, you should use `upload_endpoint` or
    # `presign_endpoint` plugins instead.*
    #
    # The `direct_upload` plugin provides a Rack endpoint which can be used for
    # uploading individual files asynchronously. It requires the [Roda] gem.
    #
    #     plugin :direct_upload
    #
    # The Roda endpoint provides two routes:
    #
    # * `POST /:storage/upload`
    # * `GET /:storage/presign`
    #
    # This first route is for doing direct uploads to your app, the received
    # file will be uploaded the underlying storage. The second route is for
    # doing direct uploads to a 3rd-party service, it will return the URL where
    # the file can be uploaded to, along with the necessary request parameters.
    #
    # This is how you can mount the endpoint in a Rails application:
    #
    #     Rails.application.routes.draw do
    #       mount ImageUploader::UploadEndpoint => "/images"
    #     end
    #
    # Now your application will get `POST /images/cache/upload` and `GET
    # /images/cache/presign` routes. On the client side it is recommended to
    # use [Uppy] for uploading files to the app or directly to the 3rd-party
    # service.
    #
    # ## Uploads
    #
    # The upload route accepts a "file" query parameter, and returns the
    # uploaded file in JSON format:
    #
    #     # POST /images/cache/upload
    #     {
    #       "id": "43kewit94.jpg",
    #       "storage": "cache",
    #       "metadata": {
    #         "size": 384393,
    #         "filename": "nature.jpg",
    #         "mime_type": "image/jpeg"
    #       }
    #     }
    #
    # Once you've uploaded the file, you can assign the result to the hidden
    # attachment field in the form, or immediately send it to the server.
    #
    # Note that the endpoint uploads the file standalone, without any knowledge
    # of the record, so `context[:record]` and `context[:name]` will be nil.
    #
    # ### Limiting filesize
    #
    # It's good idea to limit the maximum filesize of uploaded files, if you
    # set the `:max_size` option, files which are too big will get
    # automatically deleted and 413 status will be returned:
    #
    #     plugin :direct_upload, max_size: 5*1024*1024 # 5 MB
    #
    # Note that this option doesn't affect presigned uploads, there you can
    # apply filesize limit when generating a presign. The filesize constraint
    # here is for security purposes, you should still perform file validations
    # on attaching.
    #
    # ## Presigns
    #
    # The presign route returns the URL to the 3rd-party service to which you
    # can upload the file, along with the necessary query parameters.
    #
    #     # GET /images/cache/presign
    #     {
    #       "url" => "https://my-bucket.s3-eu-west-1.amazonaws.com",
    #       "fields" => {
    #         "key" => "b7d575850ba61b44c8a9ff889dfdb14d88cdc25f8dd121004c8",
    #         "policy" => "eyJleHBpcmF0aW9uIjoiMjAxNS0QwMToxMToyOVoiLCJjb25kaXRpb25zIjpbeyJidWNrZXQiOiJzaHJpbmUtdGVzdGluZyJ9LHsia2V5IjoiYjdkNTc1ODUwYmE2MWI0NGU3Y2M4YTliZmY4OGU5ZGZkYjE2NTQ0ZDk4OGNkYzI1ZjhkZDEyMTAwNGM4In0seyJ4LWFtei1jcmVkZW50aWFsIjoiQUtJQUlKRjU1VE1aWlk0NVVUNlEvMjAxNTEwMjQvZXUtd2VzdC0xL3MzL2F3czRfcmVxdWVzdCJ9LHsieC1hbXotYWxnb3JpdGhtIjoiQVdTNC1ITUFDLVNIQTI1NiJ9LHsieC1hbXotZGF0ZSI6IjIwMTUxMDI0VDAwMTEyOVoifV19",
    #         "x-amz-credential" => "AKIAIJF55TMZYT6Q/20151024/eu-west-1/s3/aws4_request",
    #         "x-amz-algorithm" => "AWS4-HMAC-SHA256",
    #         "x-amz-date" => "20151024T001129Z",
    #         "x-amz-signature" => "c1eb634f83f96b69bd675f535b3ff15ae184b102fcba51e4db5f4959b4ae26f4"
    #       }
    #     }
    #
    # If you want that the generated location includes a file extension, you
    # can specify the `extension` query parameter: `GET
    # /:storage/presign?extension=.png`.
    #
    # You can also completely change how the key is generated, with
    # `:presign_location`:
    #
    #     plugin :direct_upload, presign_location: ->(request) { "${filename}" }
    #
    # This presign route internally calls `#presign` on the storage, and many
    # storages accept additional service-specific options. You can generate
    # these additional options per-request through `:presign_options`:
    #
    #     plugin :direct_upload, presign_options: {acl: "public-read"}
    #
    #     plugin :direct_upload, presign_options: ->(request) do
    #       filename = request.params["filename"]
    #       content_type = Rack::Mime.mime_type(File.extname(filename))
    #
    #       {
    #         content_length_range: 0..(10*1024*1024),                     # limit filesize to 10MB
    #         content_disposition: "attachment; filename=\"#{filename}\"", # download with original filename
    #         content_type:        content_type,                           # set correct content type
    #       }
    #     end
    #
    # Both `:presign_location` and `:presign_options` in their block versions
    # are yielded an instance of [Roda request], which is a subclass of
    # `Rack::Request`.
    #
    # See the [Direct Uploads to S3] guide for further instructions on how to
    # hook the presigned uploads to a form.
    #
    # ## Allowed storages
    #
    # By default only uploads to `:cache` are allowed, to prevent the
    # possibility of having orphan files in your main storage. But you can
    # allow more storages:
    #
    #     plugin :direct_upload, allowed_storages: [:cache, :store]
    #
    # ## Customizing endpoint
    #
    # Since the endpoint is a [Roda] app, it is very customizable. For example,
    # you can add a Rack middleware to change the response status and headers:
    #
    #     class ShrineUploadMiddleware
    #       def initialize(app)
    #         @app = app
    #       end
    #
    #       def call(env)
    #         result = @app.call(env)
    #
    #         if result[0] == 200 && env["PATH_INFO"].end_with?("upload")
    #           result[0] = 201
    #           result[1]["Location"] = Shrine.uploaded_file(result[2].first).url
    #         end
    #
    #         result
    #       end
    #     end
    #
    #     Shrine::UploadEndpoint.use ShrineUploadMiddleware
    #
    # Upon subclassing uploader the upload endpoint is also subclassed. You can
    # also call the plugin again in an uploader subclass to change its
    # configuration.
    #
    # [Roda]: https://github.com/jeremyevans/roda
    # [Uppy]: https://uppy.io
    # [Roda request]: http://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/Base/RequestMethods.html
    # [Direct Uploads to S3]: https://shrinerb.com/rdoc/files/doc/direct_s3_md.html
    module DirectUpload
      def self.load_dependencies(uploader, *)
        uploader.plugin :rack_file
      end

      def self.configure(uploader, opts = {})
        uploader.opts[:direct_upload_allowed_storages] = opts.fetch(:allowed_storages, uploader.opts.fetch(:direct_upload_allowed_storages, [:cache]))
        uploader.opts[:direct_upload_presign_options] = opts.fetch(:presign_options, uploader.opts.fetch(:direct_upload_presign_options, {}))
        uploader.opts[:direct_upload_presign_location] = opts.fetch(:presign_location, uploader.opts[:direct_upload_presign_location])
        uploader.opts[:direct_upload_max_size] = opts.fetch(:max_size, uploader.opts[:direct_upload_max_size])

        uploader.assign_upload_endpoint(App) unless uploader.const_defined?(:UploadEndpoint)
      end

      module ClassMethods
        # Assigns the subclass a copy of the upload endpoint class.
        def inherited(subclass)
          super
          subclass.assign_upload_endpoint(self::UploadEndpoint)
        end

        # Assigns the subclassed endpoint as the `UploadEndpoint` constant.
        def assign_upload_endpoint(klass)
          endpoint_class = Class.new(klass)
          endpoint_class.opts[:shrine_class] = self
          const_set(:UploadEndpoint, endpoint_class)
        end
      end

      # Routes incoming requests. It first asserts that the storage is existent
      # and allowed, then the filesize isn't too large. Afterwards it proceeds
      # with the file upload and returns the uploaded file as JSON.
      class App < Roda
        plugin :default_headers, "Content-Type"=>"application/json"
        plugin :placeholder_string_matchers if Gem::Version.new(Roda::RodaVersion) >= Gem::Version.new("3.0.0")

        route do |r|
          r.on ":storage" do |storage_key|
            @uploader = get_uploader(storage_key)

            r.post ["upload", ":name"] do |name|
              file = get_file
              context = get_context(name)

              uploaded_file = upload(file, context)

              json uploaded_file
            end

            r.get "presign" do
              location = get_presign_location
              options = get_presign_options

              presign_data = generate_presign(location, options)
              response.headers["Cache-Control"] = "no-store"

              json presign_data
            end
          end
        end

        private

        attr_reader :uploader

        # Instantiates the uploader, checking first if the storage is allowed.
        def get_uploader(storage_key)
          allow_storage!(storage_key)
          shrine_class.new(storage_key.to_sym)
        end

        # Retrieves the context for the upload.
        def get_context(name)
          context = {action: :cache, phase: :cache}

          if name != "upload"
            Shrine.deprecation("The \"POST /:storage/:name\" route of the direct_upload plugin is deprecated, and it will be removed in Shrine 3. Use \"POST /:storage/upload\" instead.")
            context[:name] = name
          end

          unless presign_storage?
            context[:location] = request.params["key"]
          end

          context
        end

        # Uploads the file to the requested storage.
        def upload(file, context)
          uploader.upload(file, context)
        end

        # Generates a unique location, or calls `:presign_location`.
        def get_presign_location
          if presign_location
            presign_location.call(request)
          else
            extension = request.params["extension"]
            extension.prepend(".") if extension && !extension.start_with?(".")
            uploader.send(:generate_uid, nil) + extension.to_s
          end
        end

        # Returns dynamic options for generating the presign.
        def get_presign_options
          options = presign_options
          options = options.call(request) if options.respond_to?(:call)
          options || {}
        end

        # Generates the presign hash for the request.
        def generate_presign(location, options)
          if presign_storage?
            generate_real_presign(location, options)
          else
            generate_fake_presign(location, options)
          end
        end

        # Generates a presign by calling the storage.
        def generate_real_presign(location, options)
          signature = uploader.storage.presign(location, options)
          {url: signature.url, fields: signature.fields}
        end

        # Generates a presign that points to the direct upload endpoint.
        def generate_fake_presign(location, options)
          url = request.url.sub(/presign[^\/]*$/, "upload")
          {url: url, fields: {key: location}}
        end

        # Returns true if the storage supports presigns.
        def presign_storage?
          uploader.storage.respond_to?(:presign)
        end

        # Halts the request if storage is not allowed.
        def allow_storage!(storage_key)
          if !allowed_storages.map(&:to_s).include?(storage_key)
            error! 403, "Storage #{storage_key.inspect} is not allowed."
          end
        end

        # Returns the Rack file wrapped in an IO-like object. If "file" is
        # missing or is too big, the request is halted.
        def get_file
          file = require_param!("file")
          error! 400, "The \"file\" query parameter is not a file." if !(file.is_a?(Hash) && file.key?(:tempfile))
          check_filesize!(file[:tempfile]) if max_size

          RackFile::UploadedFile.new(file)
        end

        # If the file is too big, deletes the file and halts the request.
        def check_filesize!(file)
          if file.size > max_size
            file.delete
            megabytes = max_size.to_f / 1024 / 1024
            error! 413, "The file is too big (maximum size is #{megabytes} MB)."
          end
        end

        # Loudly requires the param.
        def require_param!(name)
          request.params.fetch(name)
        rescue KeyError
          error! 400, "Missing query parameter: #{name.inspect}"
        end

        # Halts the request with the error message.
        def error!(status, message)
          response.status = status
          response.write({error: message}.to_json)
          request.halt
        end

        def json(object)
          object.to_json
        end

        def shrine_class
          opts[:shrine_class]
        end

        def allowed_storages
          shrine_class.opts[:direct_upload_allowed_storages]
        end

        def presign_options
          shrine_class.opts[:direct_upload_presign_options]
        end

        def presign_location
          shrine_class.opts[:direct_upload_presign_location]
        end

        def max_size
          shrine_class.opts[:direct_upload_max_size]
        end
      end
    end

    register_plugin(:direct_upload, DirectUpload)
  end
end
