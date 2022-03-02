# frozen_string_literal: true

require "cli/ui"

module Script
  module UI
    module ErrorHandler
      def self.display(failed_op:, cause_of_error:, help_suggestion:)
        $stderr.puts(CLI::UI.fmt(ShopifyCLI::Context.message("script.error.generic")))
        full_msg = failed_op ? failed_op.dup : String.new
        append_msg(full_msg, cause_of_error) if cause_of_error
        append_msg(full_msg, help_suggestion) if help_suggestion
        $stderr.puts(CLI::UI.fmt(full_msg.strip))
      end

      def self.display_and_raise(failed_op: nil, cause_of_error: nil, help_suggestion: nil)
        display(failed_op: failed_op, cause_of_error: cause_of_error, help_suggestion: help_suggestion)
        raise(ShopifyCLI::AbortSilent)
      end

      def self.pretty_print_and_raise(e, failed_op: nil)
        messages = error_messages(e)
        raise e if messages.nil?
        display_and_raise(failed_op: failed_op, **messages)
      end

      private_class_method def self.append_msg(full_msg, msg_to_append)
        full_msg << " " unless /\s$/.match?(full_msg)
        full_msg << msg_to_append
      end

      def self.error_messages(e)
        case e
        when Errno::EACCES
          {
            cause_of_error: ShopifyCLI::Context.message("script.error.eacces_cause"),
            help_suggestion: ShopifyCLI::Context.message("script.error.eacces_help"),
          }
        when Errno::ENOSPC
          {
            cause_of_error: ShopifyCLI::Context.message("script.error.enospc_cause"),
            help_suggestion: ShopifyCLI::Context.message("script.error.enospc_help"),
          }
        when ShopifyCLI::IdentityAuth::Error
          {
            cause_of_error: ShopifyCLI::Context.message("script.error.oauth_cause"),
            help_suggestion: ShopifyCLI::Context.message("script.error.oauth_help"),
          }
        when Layers::Infrastructure::Errors::InvalidContextError
          {
            cause_of_error: ShopifyCLI::Context.message("script.error.invalid_context_cause"),
            help_suggestion: ShopifyCLI::Context.message("script.error.invalid_context_help"),
          }
        when Layers::Infrastructure::Errors::InvalidLanguageError
          {
            cause_of_error: ShopifyCLI::Context.message("script.error.invalid_language_cause", e.language),
            help_suggestion: ShopifyCLI::Context.message(
              "script.error.invalid_language_help",
              Script::Layers::Application::ExtensionPoints.languages(type: e.extension_point_type).join(", ")
            ),
          }
        when Errors::InvalidScriptTitleError
          {
            cause_of_error: ShopifyCLI::Context.message("script.error.invalid_script_title_cause"),
            help_suggestion: ShopifyCLI::Context.message("script.error.invalid_script_title_help"),
          }
        when Errors::NoExistingAppsError
          {
            cause_of_error: ShopifyCLI::Context.message("script.error.no_existing_apps_cause"),
            help_suggestion: ShopifyCLI::Context.message("script.error.no_existing_apps_help"),
          }
        when Errors::NoExistingOrganizationsError
          {
            cause_of_error: ShopifyCLI::Context.message("script.error.no_existing_orgs_cause"),
            help_suggestion: ShopifyCLI::Context.message("script.error.no_existing_orgs_help"),
          }
        when Layers::Infrastructure::Errors::ScriptProjectAlreadyExistsError
          {
            cause_of_error: ShopifyCLI::Context.message("script.error.project_exists_cause"),
            help_suggestion: ShopifyCLI::Context.message("script.error.project_exists_help"),
          }
        when Layers::Infrastructure::Errors::DeprecatedEPError
          {
            cause_of_error: ShopifyCLI::Context.message("script.error.deprecated_ep", e.extension_point),
            help_suggestion: ShopifyCLI::Context.message("script.error.deprecated_ep_cause"),
          }
        when Layers::Domain::Errors::InvalidExtensionPointError
          {
            cause_of_error: ShopifyCLI::Context.message("script.error.invalid_extension_cause", e.type),
            help_suggestion: ShopifyCLI::Context.message(
              "script.error.invalid_extension_help",
              Script::Layers::Application::ExtensionPoints.available_types.join(", ")
            ),
          }
        when Layers::Domain::Errors::ScriptNotFoundError
          {
            cause_of_error: ShopifyCLI::Context.message(
              "script.error.script_not_found_cause",
              e.title,
              e.extension_point_type
            ),
          }
        when Layers::Domain::Errors::MetadataValidationError
          {
            cause_of_error: ShopifyCLI::Context.message("script.error.metadata_validation_cause"),
            help_suggestion: ShopifyCLI::Context.message("script.error.metadata_validation_help"),
          }
        when Layers::Domain::Errors::MetadataNotFoundError
          {
            cause_of_error: ShopifyCLI::Context.message("script.error.metadata_not_found_cause", filename: e.filename),
            help_suggestion: ShopifyCLI::Context.message("script.error.metadata_not_found_help", filename: e.filename),
          }
        when Layers::Domain::Errors::MissingScriptConfigFieldError
          {
            cause_of_error: ShopifyCLI::Context.message(
              "script.error.missing_script_config_field_cause",
              field: e.field,
              filename: e.filename,
            ),
            help_suggestion: ShopifyCLI::Context.message("script.error.missing_script_config_field_help"),
          }
        when Layers::Infrastructure::Errors::BuildError
          {
            cause_of_error: ShopifyCLI::Context.message("script.error.build_error_cause"),
            help_suggestion: ShopifyCLI::Context.message("script.error.build_error_help"),
          }
        when Layers::Infrastructure::Errors::ScriptConfigParseError
          {
            cause_of_error: ShopifyCLI::Context.message(
              "script.error.script_config_parse_error_cause",
              filename: e.filename,
              serialization_format: e.serialization_format,
            ),
            help_suggestion: ShopifyCLI::Context.message("script.error.script_config_parse_error_help"),
          }
        when Layers::Infrastructure::Errors::NoScriptConfigFileError
          {
            cause_of_error: ShopifyCLI::Context.message(
              "script.error.no_script_config_file_cause",
              filename: e.filename,
            ),
            help_suggestion: ShopifyCLI::Context.message("script.error.no_script_config_file_help"),
          }
        when Layers::Infrastructure::Errors::ScriptConfigurationDefinitionError
          if e.messages.count == 1
            {
              cause_of_error: ShopifyCLI::Context.message(
                "script.error.configuration_definition_error_cause",
                message: e.messages.fetch(0),
                filename: e.filename,
              ),
              help_suggestion: ShopifyCLI::Context.message("script.error.configuration_definition_error_help"),
            }
          else
            {
              cause_of_error: ShopifyCLI::Context.message(
                "script.error.configuration_definition_errors_cause",
                concatenated_messages: e.messages.map { |m| "{{x}} #{m}" }.join("\n"),
                filename: e.filename,
                error_count: e.messages.count,
              ),
              help_suggestion: ShopifyCLI::Context.message("script.error.configuration_definition_errors_help"),
            }
          end
        when Layers::Infrastructure::Errors::ScriptConfigSyntaxError
          {
            cause_of_error: ShopifyCLI::Context.message(
              "script.error.configuration_syntax_error_cause",
              filename: e.filename,
            ),
            help_suggestion: ShopifyCLI::Context.message("script.error.configuration_syntax_error_help"),
          }
        when Layers::Infrastructure::Errors::ScriptEnvAppNotConnectedError
          {
            cause_of_error: ShopifyCLI::Context.message("script.error.app_not_connected_cause"),
            help_suggestion: ShopifyCLI::Context.message("script.error.app_not_connected_help",
              tool_name: ShopifyCLI::TOOL_NAME),
          }
        when Layers::Infrastructure::Errors::ScriptConfigMissingKeysError
          {
            cause_of_error: ShopifyCLI::Context.message(
              "script.error.configuration_missing_keys_error_cause",
              missing_keys: e.missing_keys,
              filename: e.filename,
            ),
            help_suggestion: ShopifyCLI::Context.message("script.error.configuration_missing_keys_error_help"),
          }
        when Layers::Infrastructure::Errors::ScriptConfigInvalidValueError
          {
            cause_of_error: ShopifyCLI::Context.message(
              "script.error.configuration_invalid_value_error_cause",
              valid_input_modes: e.valid_input_modes,
              filename: e.filename,
            ),
            help_suggestion: ShopifyCLI::Context.message("script.error.configuration_invalid_value_error_help"),
          }
        when Layers::Infrastructure::Errors::ScriptConfigFieldsMissingKeysError
          {
            cause_of_error: ShopifyCLI::Context.message(
              "script.error.configuration_schema_field_missing_keys_error_cause",
              missing_keys: e.missing_keys,
              filename: e.filename,
            ),
            help_suggestion: ShopifyCLI::Context.message(
              "script.error.configuration_definition_schema_field_missing_keys_error_help"
            ),
          }
        when Layers::Infrastructure::Errors::ScriptConfigFieldsInvalidValueError
          {
            cause_of_error: ShopifyCLI::Context.message(
              "script.error.configuration_schema_field_invalid_value_error_cause",
              valid_types: e.valid_types,
              filename: e.filename,
            ),
            help_suggestion: ShopifyCLI::Context.message(
              "script.error.configuration_schema_field_invalid_value_error_help"
            ),
          }
        when Layers::Infrastructure::Errors::DependencyInstallError
          {
            cause_of_error: ShopifyCLI::Context.message("script.error.dependency_install_cause"),
            help_suggestion: ShopifyCLI::Context.message("script.error.dependency_install_help"),
          }
        when Layers::Infrastructure::Errors::EmptyResponseError
          {
            cause_of_error: ShopifyCLI::Context.message("script.error.failed_api_request_cause"),
            help_suggestion: ShopifyCLI::Context.message("script.error.failed_api_request_help"),
          }
        when Layers::Infrastructure::Errors::ForbiddenError
          {
            cause_of_error: ShopifyCLI::Context.message("script.error.forbidden_error_cause"),
          }
        when Layers::Infrastructure::Errors::GraphqlError
          {
            cause_of_error: ShopifyCLI::Context.message(
              "script.error.graphql_error_cause", JSON.pretty_generate(e.errors)
            ),
            help_suggestion: ShopifyCLI::Context.message("script.error.graphql_error_help"),
          }
        when Layers::Infrastructure::Errors::InvalidEnvironmentError
          {
            cause_of_error: ShopifyCLI::Context.message(
              "script.error.invalid_environment_cause",
              tool: e.tool,
              env_version: e.env_version,
              minimum_version: e.minimum_version,
            ),
            help_suggestion: ShopifyCLI::Context.message(
              "script.error.invalid_environment_help",
              tool: e.tool,
            ),
          }
        when Layers::Infrastructure::Errors::SystemCallFailureError
          {
            cause_of_error: ShopifyCLI::Context
              .message("script.error.system_call_failure_cause", cmd: e.cmd),
            help_suggestion: ShopifyCLI::Context.message("script.error.system_call_failure_help", out: e.out),
          }
        when Layers::Infrastructure::Errors::ScriptRepushError
          {
            cause_of_error: ShopifyCLI::Context.message("script.error.script_repush_cause"),
            help_suggestion: ShopifyCLI::Context.message("script.error.script_repush_help"),
          }
        when Layers::Infrastructure::Errors::BuildScriptNotFoundError
          {
            cause_of_error: ShopifyCLI::Context.message("script.error.build_script_not_found"),
            help_suggestion: ShopifyCLI::Context.message("script.error.build_script_suggestion"),
          }
        when Layers::Infrastructure::Errors::WebAssemblyBinaryNotFoundError
          {
            cause_of_error: ShopifyCLI::Context.message("script.error.web_assembly_binary_not_found"),
            help_suggestion: ShopifyCLI::Context.message("script.error.web_assembly_binary_not_found_suggestion"),
          }
        when Layers::Infrastructure::Errors::ProjectConfigNotFoundError
          {
            cause_of_error: ShopifyCLI::Context.message("script.error.project_config_not_found"),
          }
        when Layers::Infrastructure::Errors::InvalidProjectConfigError
          {
            cause_of_error: ShopifyCLI::Context.message("script.error.invalid_project_config"),
          }
        when Layers::Infrastructure::Errors::ScriptUploadError
          {
            cause_of_error: ShopifyCLI::Context.message("script.error.script_upload_cause"),
            help_suggestion: ShopifyCLI::Context.message("script.error.script_upload_help"),
          }
        when Layers::Infrastructure::Errors::ScriptTooLargeError
          {
            cause_of_error: ShopifyCLI::Context.message("script.error.script_too_large_cause"),
            help_suggestion: ShopifyCLI::Context.message("script.error.script_too_large_help", max_size: e.max_size),
          }
        when Layers::Infrastructure::Errors::APILibraryNotFoundError
          {
            cause_of_error: ShopifyCLI::Context
              .message("script.error.api_library_not_found_cause", library_name: e.library_name),
            help_suggestion: ShopifyCLI::Context.message("script.error.api_library_not_found_help"),
          }
        when Layers::Infrastructure::Errors::LanguageLibraryForAPINotFoundError
          {
            cause_of_error: ShopifyCLI::Context
              .message(
                "script.error.language_library_for_api_not_found_cause",
                language: e.language,
                api: e.api
              ),
            help_suggestion: ShopifyCLI::Context.message("script.error.language_library_for_api_not_found_help"),
          }
        end
      end
    end
  end
end
