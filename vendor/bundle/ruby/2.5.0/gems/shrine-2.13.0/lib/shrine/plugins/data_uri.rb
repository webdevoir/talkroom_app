# frozen_string_literal: true

require "base64"
require "strscan"
require "cgi"
require "stringio"
require "forwardable"

class Shrine
  module Plugins
    # The `data_uri` plugin enables you to upload files as [data URIs].
    # This plugin is useful for example when using [HTML5 Canvas].
    #
    #     plugin :data_uri
    #
    # If your attachment is called "avatar", this plugin will add
    # `#avatar_data_uri` and `#avatar_data_uri=` methods to your model.
    #
    #     user.avatar #=> nil
    #     user.avatar_data_uri = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUA"
    #     user.avatar #=> #<Shrine::UploadedFile>
    #
    #     user.avatar.mime_type         #=> "image/png"
    #     user.avatar.size              #=> 43423
    #
    # You can also use `#data_uri=` and `#data_uri` methods directly on the
    # `Shrine::Attacher` (which the model methods just delegate to):
    #
    #     attacher.data_uri = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUA"
    #
    # If the data URI wasn't correctly parsed, an error message will be added to
    # the attachment column. You can change the default error message:
    #
    #     plugin :data_uri, error_message: "data URI was invalid"
    #     plugin :data_uri, error_message: ->(uri) { I18n.t("errors.data_uri_invalid") }
    #
    # ## File extension
    #
    # A data URI doesn't convey any information about the file extension, so
    # when attaching from a data URI, the uploaded file location will be
    # missing an extension. If you want the upload location to always have an
    # extension, you can load the `infer_extension` plugin to infer it from the
    # MIME type.
    #
    #     plugin :infer_extension
    #
    # ## `Shrine.data_uri`
    #
    # If you just want to parse the data URI and create an IO object from it,
    # you can do that with `Shrine.data_uri`. If the data URI cannot be parsed,
    # a `Shrine::Plugins::DataUri::ParseError` will be raised.
    #
    #     # or YourUploader.data_uri("...")
    #     io = Shrine.data_uri("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUA")
    #     io.content_type #=> "image/png"
    #     io.size         #=> 21
    #
    # When the content type is ommited, `text/plain` is assumed. The parser
    # also supports raw data URIs which aren't base64-encoded.
    #
    #     # or YourUploader.data_uri("...")
    #     io = Shrine.data_uri("data:,raw%20content")
    #     io.content_type #=> "text/plain"
    #     io.size         #=> 11
    #     io.read         #=> "raw content"
    #
    # ## `UploadedFile#data_uri` and `UploadedFile#base64`
    #
    # This plugin also adds UploadedFile#data_uri method, which returns a
    # base64-encoded data URI of the file content, and UploadedFile#base64,
    # which simply returns the file content base64-encoded.
    #
    #     uploaded_file.data_uri #=> "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUA"
    #     uploaded_file.base64   #=> "iVBORw0KGgoAAAANSUhEUgAAAAUA"
    #
    # [data URIs]: https://tools.ietf.org/html/rfc2397
    # [HTML5 Canvas]: https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API
    module DataUri
      class ParseError < Error; end

      DATA_REGEXP          = /data:/
      MEDIA_TYPE_REGEXP    = /[-\w.+]+\/[-\w.+]+(;[-\w.+]+=[^;,]+)*/
      BASE64_REGEXP        = /;base64/
      CONTENT_SEPARATOR    = /,/
      DEFAULT_CONTENT_TYPE = "text/plain"

      def self.configure(uploader, opts = {})
        uploader.opts[:data_uri_filename] = opts.fetch(:filename, uploader.opts[:data_uri_filename])
        uploader.opts[:data_uri_error_message] = opts.fetch(:error_message, uploader.opts[:data_uri_error_message])

        Shrine.deprecation("The :filename option is deprecated for the data_uri plugin, and will be removed in Shrine 3. Use the infer_extension plugin instead.") if opts[:filename]
      end

      module ClassMethods
        # Parses the given data URI and creates an IO object from it.
        #
        #     Shrine.data_uri("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUA")
        #     #=> #<Shrine::Plugins::DataUri::DataFile>
        def data_uri(uri)
          info = parse_data_uri(uri)

          content_type = info[:content_type] || DEFAULT_CONTENT_TYPE
          content      = info[:base64] ? Base64.decode64(info[:data]) : CGI.unescape(info[:data])
          filename     = opts[:data_uri_filename]
          filename     = filename.call(content_type) if filename

          data_file = DataFile.new(content, content_type: content_type, filename: filename)
          info[:data].clear

          data_file
        end

        private

        def parse_data_uri(uri)
          scanner = StringScanner.new(uri)
          scanner.scan(DATA_REGEXP) or raise ParseError, "data URI has invalid format"
          media_type = scanner.scan(MEDIA_TYPE_REGEXP)
          base64 = scanner.scan(BASE64_REGEXP)
          scanner.scan(CONTENT_SEPARATOR) or raise ParseError, "data URI has invalid format"

          content_type = media_type[/^[^;]+/] if media_type

          {
            content_type: content_type,
            base64:       !!base64,
            data:         scanner.post_match,
          }
        end
      end

      module AttachmentMethods
        def initialize(*)
          super

          module_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{@name}_data_uri=(uri)
              #{@name}_attacher.data_uri = uri
            end

            def #{@name}_data_uri
              #{@name}_attacher.data_uri
            end
          RUBY
        end
      end

      module AttacherMethods
        # Handles assignment of a data URI. If the regexp matches, it extracts
        # the content type, decodes it, wrappes it in a StringIO and assigns it.
        # If it fails, it sets the error message and assigns the uri in an
        # instance variable so that it shows up on the UI.
        def data_uri=(uri)
          return if uri == "" || uri.nil?

          data_file = shrine_class.data_uri(uri)
          assign(data_file)
        rescue ParseError => error
          message = shrine_class.opts[:data_uri_error_message] || error.message
          message = message.call(uri) if message.respond_to?(:call)
          errors.replace [message]
          @data_uri = uri
        end

        # Form builders require the reader as well.
        def data_uri
          @data_uri
        end
      end

      module FileMethods
        # Returns the data URI representation of the file.
        def data_uri
          @data_uri ||= "data:#{mime_type || "text/plain"};base64,#{base64}"
        end

        # Returns contents of the file base64-encoded.
        def base64
          binary = open { |io| io.read }
          result = Base64.strict_encode64(binary)
          binary.clear # deallocate string
          result
        end
      end

      class DataFile
        attr_reader :content_type, :original_filename

        def initialize(content, content_type: nil, filename: nil)
          @content_type      = content_type
          @original_filename = filename
          @io                = StringIO.new(content)
        end

        def to_io
          @io
        end

        extend Forwardable
        delegate [:read, :size, :rewind, :eof?] => :@io

        def close
          @io.close
          @io.string.clear # deallocate string
        end
      end
    end

    register_plugin(:data_uri, DataUri)
  end
end
