module ShopifyCLI
  module ExceptionReporter
    def self.report(error, _logs = nil, _api_key = nil, custom_metadata = {})
      context = ShopifyCLI::Context.new
      context.puts("\n")
      context.puts(context.message("core.error_reporting.unhandled_error.message"))
      context.puts(context.message("core.error_reporting.unhandled_error.issue_message"))
      unless ShopifyCLI::Environment.print_stacktrace?
        context.puts(context.message("core.error_reporting.unhandled_error.stacktrace_message",
          "#{ShopifyCLI::Constants::EnvironmentVariables::STACKTRACE}=1"))
      end
      context.puts("\n")

      return unless reportable_error?(error)
      return unless report?(context: context)

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

      metadata = {}
      metadata.merge!(custom_metadata)
      Bugsnag.notify(error, metadata)
    end

    def self.report?(context:)
      return false if ShopifyCLI::Environment.development?
      return true if ReportingConfigurationController.automatic_reporting_prompted? &&
        ReportingConfigurationController.can_report_automatically?

      report_error = report_error?(context: context)

      unless ReportingConfigurationController.automatic_reporting_prompted?
        ReportingConfigurationController.can_report_automatically?
      end

      report_error
    end

    def self.report_error?(context:)
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
