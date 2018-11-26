# frozen_string_literal: true

class Shrine
  module Plugins
    # The `upload_options` plugin allows you to automatically pass additional
    # upload options to storage on every upload:
    #
    #     plugin :upload_options, cache: {acl: "private"}
    #
    # Keys are names of the registered storages, and values are either hashes
    # or blocks.
    #
    #     plugin :upload_options, store: ->(io, context) do
    #       if [:original, :thumb].include?(context[:version])
    #         {acl: "public-read"}
    #       else
    #         {acl: "private"}
    #       end
    #     end
    #
    # If you're uploading the file directly, you can also pass `:upload_options`
    # to the uploader.
    #
    #     uploader.upload(file, upload_options: {acl: "public-read"})
    module UploadOptions
      def self.configure(uploader, options = {})
        uploader.opts[:upload_options] = (uploader.opts[:upload_options] || {}).merge(options)
      end

      module InstanceMethods
        def put(io, context)
          upload_options = get_upload_options(io, context)
          context = {upload_options: upload_options}.merge(context)
          super
        end

        private

        def get_upload_options(io, context)
          options = opts[:upload_options][storage_key]
          options = options.call(io, context) if options.respond_to?(:call)
          options
        end
      end
    end

    register_plugin(:upload_options, UploadOptions)
  end
end
