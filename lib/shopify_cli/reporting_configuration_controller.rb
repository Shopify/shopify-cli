module ShopifyCLI
  module ReportingConfigurationController
    def self.automatic_reporting_prompted?
      ShopifyCLI::Config.get_section(Constants::Config::Sections::Analytics::NAME).key?(
        Constants::Config::Sections::Analytics::Fields::ENABLED
      )
    end

    def self.can_report_automatically?(context: ShopifyCLI::Context.new)
      return false if ShopifyCLI::Environment.development? || ShopifyCLI::Environment.test?

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
        context.message("core.analytics.enable_prompt.question")
      ) do |handler|
        handler.option(context.message("core.analytics.enable_prompt.yes")) { |_| true }
        handler.option(context.message("core.analytics.enable_prompt.no")) { |_| false }
      end

      ShopifyCLI::Config.set(
        Constants::Config::Sections::Analytics::NAME,
        Constants::Config::Sections::Analytics::Fields::ENABLED,
        enable_automatic_tracking
      )

      enable_automatic_tracking
    end

    def self.automatic_reporting_enabled?
      ShopifyCLI::Config.get_bool(
        Constants::Config::Sections::Analytics::NAME,
        Constants::Config::Sections::Analytics::Fields::ENABLED,
        default: false
      )
    end
  end
end
