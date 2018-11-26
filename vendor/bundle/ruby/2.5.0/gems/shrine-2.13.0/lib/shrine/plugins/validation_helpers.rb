# frozen_string_literal: true

class Shrine
  module Plugins
    # The `validation_helpers` plugin provides helper methods for validating
    # attached files.
    #
    #     plugin :validation_helpers
    #
    #     Attacher.validate do
    #       validate_mime_type_inclusion %w[image/jpeg image/png image/gif]
    #       validate_max_size 5*1024*1024 if record.guest?
    #     end
    #
    # The validation methods are instance-level, the `Attacher.validate` block
    # is evaluated in context of an instance of `Shrine::Attacher`, so you can
    # easily do conditional validation.
    #
    # The validation methods return whether the validation succeeded, allowing
    # you to do conditional validation.
    #
    #     if validate_mime_type_inclusion %w[image/jpeg image/png image/gif]
    #       validate_max_width 2000
    #       validate_max_height 2000
    #     end
    #
    # If you would like to change default validation error messages, you can
    # pass in the `:default_messages` option to the plugin:
    #
    #     plugin :validation_helpers, default_messages: {
    #       max_size: ->(max) { I18n.t("errors.file.max_size", max: max) },
    #       mime_type_inclusion: ->(whitelist) { I18n.t("errors.file.mime_type_inclusion", whitelist: whitelist) },
    #     }
    #
    # If you would like to change the error message inline, you can pass the
    # `:message` option to any validation method:
    #
    #     validate_mime_type_inclusion %w[image/jpeg image/png image/gif], message: "must be JPEG, PNG or GIF"
    #
    # For a complete list of all validation helpers, see AttacherMethods.
    module ValidationHelpers
      def self.configure(uploader, opts = {})
        uploader.opts[:validation_default_messages] = (uploader.opts[:validation_default_messages] || {}).merge(opts[:default_messages] || {})
      end

      DEFAULT_MESSAGES = {
        max_size: ->(max) { "is too large (max is #{PRETTY_FILESIZE.call(max)})" },
        min_size: ->(min) { "is too small (min is #{PRETTY_FILESIZE.call(min)})" },
        max_width: ->(max) { "is too wide (max is #{max} px)" },
        min_width: ->(min) { "is too narrow (min is #{min} px)" },
        max_height: ->(max) { "is too tall (max is #{max} px)" },
        min_height: ->(min) { "is too short (min is #{min} px)" },
        mime_type_inclusion: ->(list) { "isn't of allowed type (allowed types: #{list.join(", ")})" },
        mime_type_exclusion: ->(list) { "is of forbidden type" },
        extension_inclusion: ->(list) { "isn't of allowed format (allowed formats: #{list.join(", ")})" },
        extension_exclusion: ->(list) { "is of forbidden format" },
      }

      FILESIZE_UNITS = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"].freeze

      # Returns filesize in a human readable format with units.
      # Uses the binary JEDEC unit system, i.e. 1.0 KB = 1024 bytes
      PRETTY_FILESIZE = lambda do |bytes|
        return "0.0 B" if bytes == 0

        exp = Math.log(bytes, 1024).floor
        max_exp = FILESIZE_UNITS.length - 1
        exp = max_exp if exp > max_exp
        "%.1f %s" % [bytes.to_f / 1024 ** exp, FILESIZE_UNITS[exp]]
      end

      module AttacherClassMethods
        def default_validation_messages
          @default_validation_messages ||= DEFAULT_MESSAGES.merge(
            shrine_class.opts[:validation_default_messages])
        end
      end

      module AttacherMethods
        # Validates that the file is not larger than `max`.
        def validate_max_size(max, message: nil)
          get.size <= max or add_error(:max_size, message, max) && false
        end

        # Validates that the file is not smaller than `min`.
        def validate_min_size(min, message: nil)
          get.size >= min or add_error(:min_size, message, min) && false
        end

        # Validates that the file is not wider than `max`. Requires the
        # `store_dimensions` plugin.
        def validate_max_width(max, message: nil)
          raise Error, ":store_dimensions plugin is required" if !get.respond_to?(:width)
          if get.width
            get.width <= max or add_error(:max_width, message, max) && false
          else
            Shrine.deprecation("Width of the uploaded file is nil, and Shrine skipped the validation. In Shrine 3 the validation will fail if width is nil.")
          end
        end

        # Validates that the file is not narrower than `min`. Requires the
        # `store_dimensions` plugin.
        def validate_min_width(min, message: nil)
          raise Error, ":store_dimensions plugin is required" if !get.respond_to?(:width)
          if get.width
            get.width >= min or add_error(:min_width, message, min) && false
          else
            Shrine.deprecation("Width of the uploaded file is nil, and Shrine skipped the validation. In Shrine 3 the validation will fail if width is nil.")
          end
        end

        # Validates that the file is not taller than `max`. Requires the
        # `store_dimensions` plugin.
        def validate_max_height(max, message: nil)
          raise Error, ":store_dimensions plugin is required" if !get.respond_to?(:height)
          if get.height
            get.height <= max or add_error(:max_height, message, max) && false
          else
            Shrine.deprecation("Height of the uploaded file is nil, and Shrine skipped the validation. In Shrine 3 the validation will fail if height is nil.")
          end
        end

        # Validates that the file is not shorter than `min`. Requires the
        # `store_dimensions` plugin.
        def validate_min_height(min, message: nil)
          raise Error, ":store_dimensions plugin is required" if !get.respond_to?(:height)
          if get.height
            get.height >= min or add_error(:min_height, message, min) && false
          else
            Shrine.deprecation("Height of the uploaded file is nil, and Shrine skipped the validation. In Shrine 3 the validation will fail if height is nil.")
          end
        end

        # Validates that the MIME type is in the given collection.
        #
        #     validate_mime_type_inclusion %w[audio/mp3 audio/flac]
        def validate_mime_type_inclusion(whitelist, message: nil)
          whitelist.any? { |mime_type| regex(mime_type) =~ get.mime_type.to_s } \
            or add_error(:mime_type_inclusion, message, whitelist) && false
        end

        # Validates that the MIME type is not in the given collection.
        #
        #     validate_mime_type_exclusion %w[text/x-php]
        def validate_mime_type_exclusion(blacklist, message: nil)
          blacklist.none? { |mime_type| regex(mime_type) =~ get.mime_type.to_s } \
            or add_error(:mime_type_exclusion, message, blacklist) && false
        end

        # Validates that the extension is in the given collection. Comparison
        # is case insensitive.
        #
        #     validate_extension_inclusion %w[jpg jpeg png gif]
        def validate_extension_inclusion(whitelist, message: nil)
          whitelist.any? { |extension| regex(extension) =~ get.extension.to_s } \
            or add_error(:extension_inclusion, message, whitelist) && false
        end

        # Validates that the extension is not in the given collection.
        # Comparison is case insensitive.
        #
        #     validate_extension_exclusion %[php jar]
        def validate_extension_exclusion(blacklist, message: nil)
          blacklist.none? { |extension| regex(extension) =~ get.extension.to_s } \
            or add_error(:extension_exclusion, message, blacklist) && false
        end

        private

        # Converts a string to a regex.
        def regex(value)
          if value.is_a?(Regexp)
            Shrine.deprecation("Passing regexes to type/extension whitelists/blacklists in validation_helpers plugin is deprecated and will be removed in Shrine 3. Use strings instead.")
            value
          else
            /\A#{Regexp.escape(value)}\z/i
          end
        end

        # Generates an error message and appends it to errors array.
        def add_error(*args)
          errors << error_message(*args)
        end

        # Returns the direct message if given, otherwise uses the default error
        # message.
        def error_message(type, message, object)
          message ||= self.class.default_validation_messages.fetch(type)
          message.is_a?(String) ? message : message.call(object)
        end
      end
    end

    register_plugin(:validation_helpers, ValidationHelpers)
  end
end
