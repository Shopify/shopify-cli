module ShopifyCLI
  module ExceptionReporter
    autoload :PermissionController, "shopify_cli/exception_reporter/permission_controller"

    def self.report(error, _logs = nil, _api_key = nil, custom_metadata = {})
      context = ShopifyCLI::Context.new
      context.puts("\n")
      context.puts(context.message("core.error_reporting.unhandled_error.message"))
      context.puts(context.message("core.error_reporting.unhandled_error.issue_message"))
      unless ShopifyCLI::Environment.print_backtrace?
        context.puts(context.message("core.error_reporting.unhandled_error.backtrace_message",
          "#{ShopifyCLI::Constants::EnvironmentVariables::BACKTRACE}=1"))
      end
      context.puts("\n")

      return unless reportable_error?(error)
      return unless report?

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
      # Bugsnag.notify(error, metadata)
    end

    def self.report?
      # return false if ShopifyCLI::Environment.development?
      return true if ExceptionReporter::PermissionController.automatic_reporting_prompted? &&
        ExceptionReporter::PermissionController.can_report_automatically?

      report_error = ExceptionReporter::PermissionController.report_error?

      unless ExceptionReporter::PermissionController.automatic_reporting_prompted?
        ExceptionReporter::PermissionController.can_report_automatically?
      end

      report_error
    end

    def self.reportable_error?(error)
      is_abort = error.is_a?(ShopifyCLI::Abort) || error.is_a?(ShopifyCLI::AbortSilent)
      !is_abort
    end
  end
end
