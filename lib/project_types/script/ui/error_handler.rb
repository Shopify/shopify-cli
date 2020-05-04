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
        when Errors::NoExistingAppsError
          {
            cause_of_error: "You don't have any apps.",
            help_suggestion: "Please create an app with {{command:shopify create}} or "\
                             "visit https://partners.shopify.com/.",
          }
        when Errors::NoExistingOrganizationsError
          {
            cause_of_error: "You don't have any organizations.",
            help_suggestion: "Please visit https://partners.shopify.com/ to create a partners account.",
          }
        when Errors::NoExistingStoresError
          {
            cause_of_error: "You don't have any development stores.",
            help_suggestion: "Visit https://partners.shopify.com/#{e.organization_id}/stores/ to create one.",
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
        when Layers::Infrastructure::Errors::AppNotInstalledError
          {
            cause_of_error: "App not installed on development store.",
          }
        when Layers::Infrastructure::Errors::BuildError
          {
            cause_of_error: "Something went wrong while building the script.",
            help_suggestion: "Correct the errors and try again.",
          }
        when Layers::Infrastructure::Errors::DependencyInstallError
          {
            cause_of_error: ShopifyCli::Context.message('script.error.dependency_install_cause'),
            help_suggestion: ShopifyCli::Context.message('script.error.dependency_install_help'),
          }
        when Layers::Infrastructure::Errors::ForbiddenError
          {
            cause_of_error: "You do not have permission to do this action.",
          }
        when Layers::Infrastructure::Errors::GraphqlError
          {
            cause_of_error: "An error was returned: #{e.errors.join(', ')}.",
            help_suggestion: "\nReview the error and try again.",
          }
        when Layers::Infrastructure::Errors::ScriptRedeployError
          {
            cause_of_error: "Script with the same extension point already exists on app (API key: #{e.api_key}).",
            help_suggestion: "Use {{cyan:--force}} to replace the existing script.",
          }
        when Layers::Infrastructure::Errors::ShopAuthenticationError
          {
            cause_of_error: "Unable to authenticate with the store.",
            help_suggestion: "Try again.",
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
