# frozen_string_literal: true

module ShopifyCLI
  module Theme
    class Syncer
      class Operation
        attr_accessor :method, :file

        COLOR_BY_STATUS = {
          error: :red,
          synced: :green,
          warning: :yellow,
          fixed: :cyan,
        }

        def initialize(ctx, method, file)
          @ctx = ctx
          @method = method
          @file = file
        end

        def to_s
          "#{method} #{file_path}"
        end

        def as_error_message
          as_message_with(status: :error)
        end

        def as_synced_message(color: :green)
          as_message_with(status: :synced, color: color)
        end

        def as_fix_message
          as_message_with(status: :fixed)
        end

        def file_path
          file&.relative_path
        end

        private

        def as_message_with(status:, color: nil)
          color ||= COLOR_BY_STATUS[status]
          text = @ctx.message("theme.serve.operation.status.#{status}").ljust(6)

          "#{timestamp} {{#{color}:#{text}}} {{>}} {{blue:#{self}}}"
        end

        def timestamp
          Time.now.strftime("%T")
        end
      end
    end
  end
end
