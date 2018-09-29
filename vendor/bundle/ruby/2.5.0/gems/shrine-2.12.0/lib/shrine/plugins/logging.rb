# frozen_string_literal: true

require "logger"
require "json"
require "time"

class Shrine
  module Plugins
    # The `logging` plugin logs any storing/processing/deleting that is performed.
    #
    #     plugin :logging
    #
    # This plugin is useful when you want to have overview of what exactly is
    # going on, or you simply want to have it logged for future debugging.
    # By default the logging output looks something like this:
    #
    #     2015-10-09T20:06:06.676Z #25602: STORE[cache] ImageUploader[:avatar] User[29543] 1 file (0.1s)
    #     2015-10-09T20:06:06.854Z #25602: PROCESS[store]: ImageUploader[:avatar] User[29543] 1-3 files (0.22s)
    #     2015-10-09T20:06:07.133Z #25602: DELETE[destroyed]: ImageUploader[:avatar] User[29543] 3 files (0.07s)
    #
    # The plugin accepts the following options:
    #
    # :format
    # :  This allows you to change the logging output into something that may be
    #    easier to grep. Accepts `:human` (default), `:json` and `:logfmt`.
    #
    # :stream
    # :  The default logging stream is `$stdout`, but you may want to change it,
    #    e.g. if you log into a file. This option is passed directly to
    #    `Logger.new` (from the "logger" Ruby standard library).
    #
    # :logger
    # :  This allows you to change the logger entirely. This is useful for example
    #    in Rails applications, where you might want to assign this option to
    #    `Rails.logger`.
    #
    # The default format is probably easiest to read, but may not be easiest to
    # grep. If this is important to you, you can switch to another format:
    #
    #     plugin :logging, format: :json
    #     # {"action":"upload","phase":"cache","uploader":"ImageUploader","attachment":"avatar",...}
    #
    #     plugin :logging, format: :logfmt
    #     # action=upload phase=cache uploader=ImageUploader attachment=avatar record_class=User ...
    #
    # Logging is by default disabled in tests, but you can enable it by setting
    # `Shrine.logger.level = Logger::INFO`.
    module Logging
      def self.load_dependencies(uploader, *)
        uploader.plugin :hooks
      end

      def self.configure(uploader, opts = {})
        uploader.opts[:logging_stream] = opts.fetch(:stream, uploader.opts.fetch(:logging_stream, $stdout))
        uploader.opts[:logging_logger] = opts.fetch(:logger, uploader.opts.fetch(:logging_logger, uploader.create_logger))
        uploader.opts[:logging_format] = opts.fetch(:format, uploader.opts.fetch(:logging_format, :human))

        Shrine.deprecation("The :heroku logging format has been renamed to :logfmt. Using :heroku name will stop being supported in Shrine 3.") if uploader.opts[:logging_format] == :heroku
      end

      module ClassMethods
        def logger=(logger)
          @logger = logger
        end

        def logger
          @logger ||= opts[:logging_logger]
        end

        def create_logger
          logger = Logger.new(opts[:logging_stream])
          logger.level = Logger::INFO
          logger.level = Logger::WARN if ENV["RACK_ENV"] == "test"
          logger.formatter = pretty_formatter
          logger
        end

        # It makes logging preamble simpler than the default logger. Also, it
        # doesn't output timestamps if on Heroku.
        def pretty_formatter
          proc do |severity, time, program_name, message|
            output = "#{Process.pid}: #{message}\n".dup
            output.prepend "#{time.utc.iso8601(3)} " unless ENV["DYNO"]
            output
          end
        end
      end

      module InstanceMethods
        def store(io, context = {})
          log("store", io, context) { super }
        end

        def delete(io, context = {})
          log("delete", io, context) { super }
        end

        private

        def processed(io, context = {})
          log("process", io, context) { super }
        end

        # Collects the data and sends it for logging.
        def log(action, input, context)
          result, duration = benchmark { yield }

          _log(
            action:       action,
            phase:        context[:action],
            uploader:     self.class.to_s,
            attachment:   context[:name],
            record_class: (context[:record].class.to_s if context[:record]),
            record_id:    (context[:record].id if context[:record].respond_to?(:id)),
            files:        (action == "process" ? [count(input), count(result)] : count(result)),
            duration:     ("%.2f" % duration).to_f,
          ) unless result.nil?

          result
        end

        # Determines format of logging and calls appropriate method.
        def _log(data)
          message = send("_log_message_#{opts[:logging_format]}", data)
          self.class.logger.info(message)
        end

        def _log_message_human(data)
          components = []
          components << "#{data[:action].upcase}"
          components[-1] += "[#{data[:phase]}]" if data[:phase]
          components << "#{data[:uploader]}"
          components[-1] += "[:#{data[:attachment]}]" if data[:attachment]
          components << "#{data[:record_class]}" if data[:record_class]
          components[-1] += "[#{data[:record_id]}]" if data[:record_id]
          components << "#{Array(data[:files]).join("-")} #{"file#{"s" if Array(data[:files]).any?{|n| n > 1}}"}"
          components << "(#{data[:duration]}s)"
          components.join(" ")
        end

        def _log_message_json(data)
          data[:files] = Array(data[:files]).join("-")
          JSON.generate(data)
        end

        def _log_message_logfmt(data)
          data[:files] = Array(data[:files]).join("-")
          data.map { |key, value| "#{key}=#{value}" }.join(" ")
        end
        alias _log_message_heroku _log_message_logfmt # deprecated alias

        # We may have one file, a hash of versions, or an array of files or
        # hashes.
        def count(object)
          case object
          when Hash
            object.count
          when Array
            object.inject(0) { |sum, o| sum += count(o) }
          else
            1
          end
        end

        def benchmark
          start = Time.now
          result = yield
          finish = Time.now
          [result, finish - start]
        end
      end
    end

    register_plugin(:logging, Logging)
  end
end
