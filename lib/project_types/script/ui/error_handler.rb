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
        when Errors::InvalidConfigProps
          {
            cause_of_error: ShopifyCli::Context.message('script.error.invalid_config_props_cause'),
            help_suggestion: ShopifyCli::Context.message('script.error.invalid_config_props_help'),
          }
        when Errors::InvalidConfigYAMLError
          {
            cause_of_error: ShopifyCli::Context.message('script.error.invalid_config', e.config_file),
          }
        when Errors::InvalidScriptNameError
          {
            cause_of_error: ShopifyCli::Context.message('script.error.invalid_script_name_cause'),
            help_suggestion: ShopifyCli::Context.message('script.error.invalid_script_name_help'),
          }
        when Errors::NoExistingAppsError
          {
            cause_of_error: ShopifyCli::Context.message('script.error.no_existing_apps_cause'),
            help_suggestion: ShopifyCli::Context.message('script.error.no_existing_apps_help'),
          }
        when Errors::NoExistingOrganizationsError
          {
            cause_of_error: ShopifyCli::Context.message('script.error.no_existing_orgs_cause'),
            help_suggestion: ShopifyCli::Context.message('script.error.no_existing_orgs_help'),
          }
        when Errors::NoExistingStoresError
          {
            cause_of_error: ShopifyCli::Context.message('script.error.no_existing_stores_cause'),
            help_suggestion: ShopifyCli::Context.message(
              'script.error.no_existing_stores_help',
              organization_id: e.organization_id
            ),
          }
        when Errors::ScriptProjectAlreadyExistsError
          {
            cause_of_error: ShopifyCli::Context.message('script.error.project_exists_cause'),
            help_suggestion: ShopifyCli::Context.message('script.error.project_exists_help'),
          }
        when Layers::Domain::Errors::InvalidExtensionPointError
          {
            cause_of_error: ShopifyCli::Context.message('script.error.invalid_extension_cause', e.type),
            help_suggestion: ShopifyCli::Context.message(
              'script.error.invalid_extension_help',
             Script::Layers::Application::ExtensionPoints.types.join(', ')
            ),
          }
        when Layers::Domain::Errors::ScriptNotFoundError
          {
            cause_of_error: ShopifyCli::Context.message(
              'script.error.script_not_found_cause',
              e.script_name,
              e.extension_point_type
            ),
          }
        when Layers::Infrastructure::Errors::AppNotInstalledError
          {
            cause_of_error: ShopifyCli::Context.message('script.error.app_not_installed_cause'),
          }
        when Layers::Infrastructure::Errors::AppScriptNotPushedError,
          Layers::Infrastructure::Errors::AppScriptUndefinedError
          {
            cause_of_error: ShopifyCli::Context.message('script.error.app_script_not_pushed_help'),
          }
        when Layers::Infrastructure::Errors::BuildError
          {
            cause_of_error: ShopifyCli::Context.message('script.error.build_error_cause'),
            help_suggestion: ShopifyCli::Context.message('script.error.build_error_help'),
          }
        when Layers::Infrastructure::Errors::DependencyInstallError
          {
            cause_of_error: ShopifyCli::Context.message('script.error.dependency_install_cause'),
            help_suggestion: ShopifyCli::Context.message('script.error.dependency_install_help'),
          }
        when Layers::Infrastructure::Errors::ForbiddenError
          {
            cause_of_error: ShopifyCli::Context.message('script.error.forbidden_error_cause'),
          }
        when Layers::Infrastructure::Errors::GraphqlError
          {
            cause_of_error: ShopifyCli::Context.message('script.error.graphql_error_cause', e.errors.join(', ')),
            help_suggestion: ShopifyCli::Context.message('script.error.graphql_error_help'),
          }
        when Layers::Infrastructure::Errors::ScriptRepushError
          {
            cause_of_error: ShopifyCli::Context.message('script.error.script_repush_cause', e.api_key),
            help_suggestion: ShopifyCli::Context.message('script.error.script_repush_help'),
          }
        when Layers::Infrastructure::Errors::ShopAuthenticationError
          {
            cause_of_error: ShopifyCli::Context.message('script.error.shop_auth_cause'),
            help_suggestion: ShopifyCli::Context.message('script.error.shop_auth_help'),
          }
        when Layers::Infrastructure::Errors::ShopScriptConflictError
          {
            cause_of_error: ShopifyCli::Context.message('script.error.shop_script_conflict_cause'),
            help_suggestion: ShopifyCli::Context.message('script.error.shop_script_conflict_help'),
          }
        when Layers::Infrastructure::Errors::ShopScriptUndefinedError
          {
            cause_of_error: ShopifyCli::Context.message('script.error.shop_script_undefined_cause'),
          }
        when Layers::Infrastructure::Errors::PackagesOutdatedError
          {
            cause_of_error: ShopifyCli::Context.message(
              'script.error.packages_outdated_cause',
              e.outdated_packages.join(', ')
            ),
            help_suggestion: ShopifyCli::Context.message(
              'script.error.packages_outdated_help',
              e.outdated_packages.collect { |package| "#{package}@latest" }.join(' ')
            ),
          }
        end
      end
    end
  end
end
