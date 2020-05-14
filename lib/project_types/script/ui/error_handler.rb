require 'cli/ui'

module Script
  module UI
    module ErrorHandler
      def self.display(failed_op:, cause_of_error:, help_suggestion:)
        $stderr.puts(CLI::UI.fmt(ShopifyCli::Context.message('script.error.generic')))
        full_msg = failed_op ? failed_op.dup : ""
        full_msg << " #{cause_of_error}" if cause_of_error
        full_msg << " #{help_suggestion}" if help_suggestion
        $stderr.puts(CLI::UI.fmt(full_msg.strip))
      end

      def self.display_and_raise(failed_op: nil, cause_of_error: nil, help_suggestion: nil)
        display(failed_op: failed_op, cause_of_error: cause_of_error, help_suggestion: help_suggestion)
        raise(ShopifyCli::AbortSilent)
      end

      def self.pretty_print_and_raise(e, failed_op: nil)
        messages = error_messages(e)
        raise e if messages.nil?
        display_and_raise(failed_op: failed_op, **messages)
      end

      def self.error_messages(e)
        case e
        when Errno::EACCES
          {
            cause_of_error: ShopifyCli::Context.message('script.error.eacces_cause'),
            help_suggestion: ShopifyCli::Context.message('script.error.eacces_help'),
          }
        when Errno::ENOSPC
          {
            cause_of_error: ShopifyCli::Context.message('script.error.enospc_cause'),
            help_suggestion: ShopifyCli::Context.message('script.error.enospc_help'),
          }
        when ShopifyCli::OAuth::Error
          {
            cause_of_error: ShopifyCli::Context.message('script.error.oauth_cause'),
            help_suggestion: ShopifyCli::Context.message('script.error.oauth_help'),
          }
        when Errors::InvalidContextError
          {
            cause_of_error: ShopifyCli::Context.message('script.error.invalid_context_cause'),
            help_suggestion: ShopifyCli::Context.message('script.error.invalid_context_help'),
          }
        when Errors::ScriptProjectAlreadyExistsError
          {
            cause_of_error: ShopifyCli::Context.message('script.error.project_exists_cause'),
            help_suggestion: ShopifyCli::Context.message('script.error.project_exists_help'),
          }
        when Layers::Domain::Errors::InvalidExtensionPointError
          {
            cause_of_error: ShopifyCli::Context.message('script.error.invalid_extension_cause', e.type),
            help_suggestion: ShopifyCli::Context.message('script.error.invalid_extension_help'),
          }
        when Layers::Domain::Errors::ScriptNotFoundError
          {
            cause_of_error: ShopifyCli::Context.message(
              'script.error.script_not_found_cause', e.script_name, e.extension_point_type
            ),
          }
        when Layers::Infrastructure::Errors::DependencyInstallError
          {
            cause_of_error: ShopifyCli::Context.message('script.error.dependency_install_cause'),
            help_suggestion: ShopifyCli::Context.message('script.error.dependency_install_help'),
          }
        when Layers::Infrastructure::Errors::TestError
          {
            help_suggestion: ShopifyCli::Context.message('script.error.test_help'),
          }
        end
      end
    end
  end
end
