module ShopifyCLI
  module ExceptionReporter
    module PermissionController
      def self.report_error?(context: ShopifyCLI::Context.new)
        CLI::UI::Prompt.ask(context.message("core.error_reporting.report_error.question")) do |handler|
          handler.option(context.message("core.error_reporting.report_error.yes")) { |_| true }
          handler.option(context.message("core.error_reporting.report_error.no")) { |_| false }
        end
      end

      def self.automatic_reporting_prompted?
        ShopifyCLI::Config.get_section(Constants::Config::Sections::ErrorTracking::NAME).key?(
          Constants::Config::Sections::ErrorTracking::Fields::AUTOMATIC_REPORTING
        )
      end

      def self.can_report_automatically?(context: ShopifyCLI::Context.new)
        # If the terminal is not interactive we can't prompt the user.
        return false unless ShopifyCLI::Environment.interactive?

        if automatic_reporting_prompted?
          automatic_reporting_enabled?
        else
          prompt_user(context: context)
        end
      end

      def self.prompt_user(context:)
        enable_automatic_tracking = CLI::UI::Prompt.ask(
          context.message("core.error_reporting.enable_automatic_reporting_prompt.question")
        ) do |handler|
          handler.option(context.message("core.error_reporting.enable_automatic_reporting_prompt.yes")) { |_| true }
          handler.option(context.message("core.error_reporting.enable_automatic_reporting_prompt.no")) { |_| false }
        end

        ShopifyCLI::Config.set(
          Constants::Config::Sections::ErrorTracking::NAME,
          Constants::Config::Sections::ErrorTracking::Fields::AUTOMATIC_REPORTING,
          enable_automatic_tracking
        )

        enable_automatic_tracking
      end

      def self.automatic_reporting_enabled?
        ShopifyCLI::Config.get_bool(
          Constants::Config::Sections::ErrorTracking::NAME,
          Constants::Config::Sections::ErrorTracking::Fields::AUTOMATIC_REPORTING,
          default: false
        )
      end
    end
  end
end
