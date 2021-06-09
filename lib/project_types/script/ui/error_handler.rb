require "cli/ui"

module Script
  module UI
    module ErrorHandler
      def self.display(failed_op:, cause_of_error:, help_suggestion:)
        $stderr.puts(CLI::UI.fmt(ShopifyCli::Context.message("script.error.generic")))
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
            cause_of_error: ShopifyCli::Context.message("script.error.eacces_cause"),
            help_suggestion: ShopifyCli::Context.message("script.error.eacces_help"),
          }
        when Errno::ENOSPC
          {
            cause_of_error: ShopifyCli::Context.message("script.error.enospc_cause"),
            help_suggestion: ShopifyCli::Context.message("script.error.enospc_help"),
          }
        when ShopifyCli::OAuth::Error
          {
            cause_of_error: ShopifyCli::Context.message("script.error.oauth_cause"),
            help_suggestion: ShopifyCli::Context.message("script.error.oauth_help"),
          }
        when Layers::Infrastructure::Errors::InvalidContextError
          {
            cause_of_error: ShopifyCli::Context.message("script.error.invalid_context_cause"),
            help_suggestion: ShopifyCli::Context.message("script.error.invalid_context_help"),
          }
        when Errors::InvalidConfigProps
          {
            cause_of_error: ShopifyCli::Context.message("script.error.invalid_config_props_cause"),
            help_suggestion: ShopifyCli::Context.message("script.error.invalid_config_props_help"),
          }
        when Errors::InvalidConfigYAMLError
          {
            cause_of_error: ShopifyCli::Context.message("script.error.invalid_config", e.config_file),
          }
        when Layers::Infrastructure::Errors::InvalidLanguageError
          {
            cause_of_error: ShopifyCli::Context.message("script.error.invalid_language_cause", e.language),
            help_suggestion: ShopifyCli::Context.message(
              "script.error.invalid_language_help",
              Script::Layers::Application::ExtensionPoints.languages(type: e.extension_point_type).join(", ")
            ),
          }
        when Errors::InvalidScriptNameError
          {
            cause_of_error: ShopifyCli::Context.message("script.error.invalid_script_name_cause"),
            help_suggestion: ShopifyCli::Context.message("script.error.invalid_script_name_help"),
          }
        when Errors::NoExistingAppsError
          {
            cause_of_error: ShopifyCli::Context.message("script.error.no_existing_apps_cause"),
            help_suggestion: ShopifyCli::Context.message("script.error.no_existing_apps_help"),
          }
        when Errors::NoExistingOrganizationsError
          {
            cause_of_error: ShopifyCli::Context.message("script.error.no_existing_orgs_cause"),
            help_suggestion: ShopifyCli::Context.message("script.error.no_existing_orgs_help"),
          }
        when Errors::NoExistingStoresError
          {
            cause_of_error: ShopifyCli::Context.message("script.error.no_existing_stores_cause"),
            help_suggestion: ShopifyCli::Context.message(
              "script.error.no_existing_stores_help",
              organization_id: e.organization_id
            ),
          }
        when Layers::Infrastructure::Errors::ScriptProjectAlreadyExistsError
          {
            cause_of_error: ShopifyCli::Context.message("script.error.project_exists_cause"),
            help_suggestion: ShopifyCli::Context.message("script.error.project_exists_help"),
          }
        when Layers::Infrastructure::Errors::DeprecatedEPError
          {
            cause_of_error: ShopifyCli::Context.message("script.error.deprecated_ep", e.ep),
            help_suggestion: ShopifyCli::Context.message("script.error.deprecated_ep_cause"),
          }
        when Layers::Domain::Errors::InvalidExtensionPointError
          {
            cause_of_error: ShopifyCli::Context.message("script.error.invalid_script_api_cause", e.type),
            help_suggestion: ShopifyCli::Context.message(
              "script.error.invalid_script_api_help",
              Script::Layers::Application::ExtensionPoints.types.join(", ")
            ),
          }
        when Layers::Domain::Errors::ScriptNotFoundError
          {
            cause_of_error: ShopifyCli::Context.message(
              "script.error.script_not_found_cause",
              e.script_name,
              e.extension_point_type
            ),
          }
        when Layers::Domain::Errors::MetadataValidationError
          {
            cause_of_error: ShopifyCli::Context.message("script.error.metadata_validation_cause"),
            help_suggestion: ShopifyCli::Context.message("script.error.metadata_validation_help"),
          }
        when Layers::Domain::Errors::MetadataNotFoundError
          {
            cause_of_error: ShopifyCli::Context.message("script.error.metadata_not_found_cause"),
            help_suggestion: ShopifyCli::Context.message("script.error.metadata_not_found_help"),
          }
        when Layers::Domain::Errors::InvalidConfigUiDefinitionError
          {
            cause_of_error: ShopifyCli::Context
              .message("script.error.invalid_config_ui_definition_cause", e.filename),
            help_suggestion: ShopifyCli::Context.message("script.error.invalid_config_ui_definition_help"),
          }
        when Layers::Domain::Errors::MissingSpecifiedConfigUiDefinitionError
          {
            cause_of_error: ShopifyCli::Context
              .message("script.error.missing_config_ui_definition_cause", e.filename),
            help_suggestion: ShopifyCli::Context.message("script.error.missing_config_ui_definition_help"),
          }
        when Layers::Infrastructure::Errors::AppNotInstalledError
          {
            cause_of_error: ShopifyCli::Context.message("script.error.app_not_installed_cause"),
          }
        when Layers::Infrastructure::Errors::BuildError
          {
            cause_of_error: ShopifyCli::Context.message("script.error.build_error_cause"),
            help_suggestion: ShopifyCli::Context.message("script.error.build_error_help"),
          }
        when Layers::Infrastructure::Errors::ConfigUiSyntaxError
          {
            cause_of_error: ShopifyCli::Context.message(
              "script.error.config_ui_syntax_error_cause",
              filename: e.message
            ),
            help_suggestion: ShopifyCli::Context.message("script.error.config_ui_syntax_error_help"),
          }
        when Layers::Infrastructure::Errors::ConfigUiMissingKeysError
          {
            cause_of_error: ShopifyCli::Context.message(
              "script.error.config_ui_missing_keys_error_cause",
              filename: e.filename,
              missing_keys: e.missing_keys
            ),
            help_suggestion: ShopifyCli::Context.message("script.error.config_ui_missing_keys_error_help"),
          }
        when Layers::Infrastructure::Errors::ConfigUiInvalidInputModeError
          {
            cause_of_error: ShopifyCli::Context.message(
              "script.error.config_ui_invalid_input_mode_error_cause",
              filename: e.filename,
              valid_input_modes: e.valid_input_modes
            ),
            help_suggestion: ShopifyCli::Context.message("script.error.config_ui_invalid_input_mode_error_help"),
          }
        when Layers::Infrastructure::Errors::ConfigUiFieldsMissingKeysError
          {
            cause_of_error: ShopifyCli::Context.message(
              "script.error.config_ui_fields_missing_keys_error_cause",
              filename: e.filename,
              missing_keys: e.missing_keys
            ),
            help_suggestion: ShopifyCli::Context.message("script.error.config_ui_fields_missing_keys_error_help"),
          }
        when Layers::Infrastructure::Errors::ConfigUiFieldsInvalidTypeError
          {
            cause_of_error: ShopifyCli::Context.message(
              "script.error.config_ui_fields_invalid_type_error_cause",
              filename: e.filename,
              valid_types: e.valid_types
            ),
            help_suggestion: ShopifyCli::Context.message("script.error.config_ui_fields_invalid_type_error_help"),
          }
        when Layers::Infrastructure::Errors::DependencyInstallError
          {
            cause_of_error: ShopifyCli::Context.message("script.error.dependency_install_cause"),
            help_suggestion: ShopifyCli::Context.message("script.error.dependency_install_help"),
          }
        when Layers::Infrastructure::Errors::EmptyResponseError
          {
            cause_of_error: ShopifyCli::Context.message("script.error.failed_api_request_cause"),
            help_suggestion: ShopifyCli::Context.message("script.error.failed_api_request_help"),
          }
        when Layers::Infrastructure::Errors::ForbiddenError
          {
            cause_of_error: ShopifyCli::Context.message("script.error.forbidden_error_cause"),
          }
        when Layers::Infrastructure::Errors::GraphqlError
          {
            cause_of_error: ShopifyCli::Context.message(
              "script.error.graphql_error_cause", JSON.pretty_generate(e.errors)
            ),
            help_suggestion: ShopifyCli::Context.message("script.error.graphql_error_help"),
          }
        when Layers::Infrastructure::Errors::SystemCallFailureError
          {
            cause_of_error: ShopifyCli::Context
              .message("script.error.system_call_failure_cause", cmd: e.cmd),
            help_suggestion: ShopifyCli::Context.message("script.error.system_call_failure_help", out: e.out),
          }
        when Layers::Infrastructure::Errors::ScriptRepushError
          {
            cause_of_error: ShopifyCli::Context.message("script.error.script_repush_cause", e.uuid),
            help_suggestion: ShopifyCli::Context.message("script.error.script_repush_help"),
          }
        when Layers::Infrastructure::Errors::ShopAuthenticationError
          {
            cause_of_error: ShopifyCli::Context.message("script.error.shop_auth_cause"),
            help_suggestion: ShopifyCli::Context.message("script.error.shop_auth_help"),
          }
        when Layers::Infrastructure::Errors::BuildScriptNotFoundError
          {
            cause_of_error: ShopifyCli::Context.message("script.error.build_script_not_found"),
            help_suggestion: ShopifyCli::Context.message("script.error.build_script_suggestion"),
          }
        when Layers::Infrastructure::Errors::InvalidBuildScriptError
          {
            cause_of_error: ShopifyCli::Context.message("script.error.invalid_build_script"),
            help_suggestion: ShopifyCli::Context.message("script.error.build_script_suggestion"),
          }
        when Layers::Infrastructure::Errors::WebAssemblyBinaryNotFoundError
          {
            cause_of_error: ShopifyCli::Context.message("script.error.web_assembly_binary_not_found"),
            help_suggestion: ShopifyCli::Context.message("script.error.web_assembly_binary_not_found_suggestion"),
          }
        end
      end
    end
  end
end
