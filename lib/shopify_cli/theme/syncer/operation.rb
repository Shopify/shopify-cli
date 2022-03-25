# frozen_string_literal: true

module ShopifyCLI
  module Theme
    class Syncer
      class Operation
        attr_accessor :method, :file

        COLOR_BY_STATUS = {
          error: :red,
          synced: :green,
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

        def as_synced_message
          as_message_with(status: :synced)
        end

        def as_fix_message
          as_message_with(status: :fixed)
        end

        def file_path
          file&.relative_path
        end

        private

        def as_message_with(status:)
          status_color = COLOR_BY_STATUS[status]
          status_text = @ctx.message("theme.serve.operation.status.#{status}").ljust(6)

          "#{timestamp} {{#{status_color}:#{status_text}}} {{>}} {{blue:#{self}}}"
        end

        def timestamp
          Time.now.strftime("%T")
        end
      end
    end
  end
end
