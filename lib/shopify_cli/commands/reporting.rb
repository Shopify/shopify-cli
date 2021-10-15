require "shopify_cli"

module ShopifyCLI
  module Commands
    class Reporting < ShopifyCLI::Command
      def call(args, _name)
        enable_reporting = reporting_enabled?(args)
        Services::ReportingService.call(enable: enable_reporting)

        message = if enable_reporting
          @ctx.message("core.reporting.turned_on_message")
        else
          @ctx.message("core.reporting.turned_off_message", ShopifyCLI::TOOL_NAME)
        end
        @ctx.puts(message)
      end

      def reporting_enabled?(args)
        case args.first
        when nil
          @ctx.abort(@ctx.message("core.reporting.missing_argument", ShopifyCLI::TOOL_NAME))
        when "on"
          true
        when "off"
          false
        else
          @ctx.abort(
            @ctx.message("core.reporting.invalid_argument", ShopifyCLI::TOOL_NAME, args.first)
          )
        end
      end

      def self.help
        ShopifyCLI::Context.message("core.reporting.help", ShopifyCLI::TOOL_NAME)
      end
    end
  end
end
