# frozen_string_literal: true

module ShopifyCLI
  module Theme
    class Syncer
      ##
      # ShopifyCLI::Theme::Syncer::StdReporter allows disabling/enabling
      # messages reported in the standard error output (ShopifyCLI::Context#puts).
      #
      class StandardReporter
        attr_reader :ctx

        def initialize(ctx)
          @enabled = true
          @ctx = ctx
        end

        def disable!
          @enabled = false
        end

        def enable!
          @enabled = true
        end

        def report(message)
          ctx.error(message) if @enabled
        end
      end
    end
  end
end
