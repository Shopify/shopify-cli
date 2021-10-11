module ShopifyCLI
  module ReportingConfigurationController
    def self.enable_reporting(enabled)
      ShopifyCLI::Config.set(
        Constants::Config::Sections::Analytics::NAME,
        Constants::Config::Sections::Analytics::Fields::ENABLED,
        enabled
      )
    end

    def self.reporting_prompted?
      ShopifyCLI::Config.get_section(Constants::Config::Sections::Analytics::NAME).key?(
        Constants::Config::Sections::Analytics::Fields::ENABLED
      )
    end

    def self.reporting_enabled?
      ShopifyCLI::Config.get_bool(
        Constants::Config::Sections::Analytics::NAME,
        Constants::Config::Sections::Analytics::Fields::ENABLED,
        default: false
      )
    end

    def self.check_or_prompt_report_automatically(prompt: true, context: ShopifyCLI::Context.new)
      return false if ShopifyCLI::Environment.development? || ShopifyCLI::Environment.test?

      # If the terminal is not interactive we can't prompt the user.
      return false unless ShopifyCLI::Environment.interactive?

      if reporting_prompted?
        reporting_enabled?
      elsif prompt
        prompt_user(context: context)
      else
        false
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

      message = if enable_automatic_tracking
        context.message("core.reporting.turned_on_message")
      else
        context.message("core.reporting.turned_off_message", ShopifyCLI::TOOL_NAME)
      end
      context.puts(message)

      enable_automatic_tracking
    end
  end
end
