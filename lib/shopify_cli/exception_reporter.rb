module ShopifyCLI
  module ExceptionReporter
    def self.report_error_silently(error)
      return unless ReportingConfigurationController.reporting_enabled?
      report_to_bugsnag(error: error)
    end

    def self.report(error, _logs = nil, _api_key = nil, custom_metadata = {})
      context = ShopifyCLI::Context.new
      unless ShopifyCLI::Environment.development?
        context.puts(context.message("core.error_reporting.unhandled_error.message"))
        context.puts(context.message("core.error_reporting.unhandled_error.issue_message",
          ShopifyCLI::GitHub::IssueURLGenerator.error_url(error)))
      end

      # Stack trace hint
      unless ShopifyCLI::Environment.print_stacktrace?
        context.puts(context.message("core.error_reporting.unhandled_error.stacktrace_message",
          "#{ShopifyCLI::Constants::EnvironmentVariables::STACKTRACE}=1"))
      end

      context.puts("\n")

      return unless reportable_error?(error)

      return unless report?(context: context)
      report_to_bugsnag(error: error, custom_metadata: custom_metadata)
    end

    def self.report_to_bugsnag(error:, custom_metadata: {})
      ENV["BUGSNAG_DISABLE_AUTOCONFIGURE"] = "1"
      require "bugsnag"

      Bugsnag.configure do |config|
        config.logger.level = ::Logger::ERROR
        config.api_key = ShopifyCLI::Constants::Bugsnag::API_KEY
        config.app_type = "shopify"
        config.project_root = File.expand_path("../../..", __FILE__)
        config.app_version = ShopifyCLI::VERSION
        config.auto_capture_sessions = false
      end

      metadata = { rubyPlatform: RUBY_PLATFORM }
      metadata.merge!(custom_metadata)

      Bugsnag.notify(error) do |event|
        event.add_metadata(:device, metadata)
      end
    rescue
      nil
    end

    def self.report?(context:)
      return true if ReportingConfigurationController.reporting_prompted? &&
        ReportingConfigurationController.check_or_prompt_report_automatically(source: :uncaught_error)

      report_error = report_error?(context: context)

      unless ReportingConfigurationController.reporting_prompted?
        ReportingConfigurationController.check_or_prompt_report_automatically(source: :uncaught_error)
      end
      report_error
    end

    def self.report_error?(context:)
      return false if Environment.development?

      CLI::UI::Prompt.ask(context.message("core.error_reporting.report_error.question")) do |handler|
        handler.option(context.message("core.error_reporting.report_error.yes")) { |_| true }
        handler.option(context.message("core.error_reporting.report_error.no")) { |_| false }
      end
    end

    def self.reportable_error?(error)
      is_abort = error.is_a?(ShopifyCLI::Abort) || error.is_a?(ShopifyCLI::AbortSilent)
      !is_abort
    end
  end
end
