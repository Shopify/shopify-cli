# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class ScriptProjectRepository
        include SmartProperties
        property! :ctx, accepts: ShopifyCli::Context

        DEFAULT_CONFIG_UI_FILENAME = "config-ui.yml"

        def create(script_name:, extension_point_type:, language:, no_config_ui:)
          validate_metadata!(extension_point_type, language)

          optional_identifiers = {}
          config_ui_file = nil

          unless no_config_ui
            optional_identifiers.merge!(config_ui_file: DEFAULT_CONFIG_UI_FILENAME)
            # TODO: remove this repo and make it an implementation detail
            config_ui_file = Infrastructure::ConfigUiRepository
              .new(ctx: ctx)
              .create_config_ui(DEFAULT_CONFIG_UI_FILENAME, default_config_ui_content(script_name))
          end

          ShopifyCli::Project.write(
            ctx,
            project_type: :script,
            organization_id: nil,
            extension_point_type: extension_point_type,
            script_name: script_name,
            language: language,
            **optional_identifiers
          )

          Domain::ScriptProject.new(
            id: ctx.root,
            env: project.env,
            script_name: script_name,
            extension_point_type: extension_point_type,
            language: language,
            config_ui: config_ui_file
          )
        end

        def get
          extension_point_type = project_config_value!("extension_point_type")
          script_name = project_config_value!("script_name")
          config_ui_file = project_config_value("config_ui_file")
          language = project_config_value("language")&.downcase || default_language

          validate_metadata!(extension_point_type, language)

          # TODO: remove this repo and make it an implementation detail
          config_ui = Infrastructure::ConfigUiRepository.new(ctx: ctx).get_config_ui(config_ui_file)

          Domain::ScriptProject.new(
            id: project.directory,
            env: project.env,
            script_name: script_name,
            extension_point_type: extension_point_type,
            language: language,
            config_ui: config_ui
          )
        end

        private

        def project_config_value(key)
          return nil unless project.config.key?(key)
          project.config[key]
        end

        def project_config_value!(key)
          raise Errors::InvalidContextError, key unless project.config.key?(key)
          project.config[key]
        end

        def project
          ShopifyCli::Project.current
        end

        def default_config_ui_content(title)
          YAML.dump({
            "version" => 1,
            "type" => "single",
            "title" => title,
            "description" => "",
            "fields" => [],
          })
        end

        def default_language
          Domain::ExtensionPoint::ExtensionPointAssemblyScriptSDK.language
        end

        def validate_metadata!(extension_point_type, language)
          if Application::ExtensionPoints.deprecated_types.include?(extension_point_type)
            raise Errors::DeprecatedEPError, extension_point_type
          elsif !Application::ExtensionPoints.supported_language?(type: extension_point_type, language: language)
            raise Errors::InvalidLanguageError.new(language, extension_point_type)
          end
        end
      end
    end
  end
end
