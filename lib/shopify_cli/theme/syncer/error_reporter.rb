# frozen_string_literal: true

module ShopifyCLI
  module Theme
    class Syncer
      ##
      # ShopifyCLI::Theme::Syncer::ErrorReporter allows delaying log of errors,
      # mainly to not break the progress bar.
      #
      class ErrorReporter
        attr_reader :ctx, :delayed_errors

        def initialize(ctx)
          @ctx = ctx
          @has_any_error = false
          @delay_errors = false
          @delayed_errors = []
        end

        def delay_errors!
          @delay_errors = true
        end

        def report_errors!
          @delay_errors = false
          @delayed_errors.each { |error| report_error(error) }
          @delayed_errors.clear
        end

        def report_error(error_message)
          if @delay_errors
            @delayed_errors << error_message
          else
            @has_any_error = true
            @ctx.puts(error_message)
          end
        end

        def has_any_error?
          @has_any_error
        end
      end
    end
  end
end
