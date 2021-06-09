# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class ScriptProjectRepository
        include SmartProperties
        property! :ctx, accepts: ShopifyCli::Context

        DEFAULT_CONFIG_UI_FILENAME = "config-ui.yml"
        MUTABLE_ENV_VALUES = %i(uuid)

        def create(script_name:, script_api_type:, language:, no_config_ui:)
          validate_metadata!(script_api_type, language)

          config_ui_file = nil
          optional_identifiers = {}
          optional_identifiers.merge!(config_ui_file: DEFAULT_CONFIG_UI_FILENAME) unless no_config_ui

          ShopifyCli::Project.write(
            ctx,
            project_type: :script,
            organization_id: nil,
            script_api_type: script_api_type,
            script_name: script_name,
            language: language,
            **optional_identifiers
          )

          Domain::ScriptProject.new(
            id: ctx.root,
            env: project.env,
            script_name: script_name,
            script_api_type: script_api_type,
            language: language,
            config_ui: config_ui_file
          )
        end

        def get
          validate_metadata!(script_api_type, language)

          config_ui = ConfigUiRepository.new(ctx: ctx).get(config_ui_file)

          Domain::ScriptProject.new(
            id: project.directory,
            env: project.env,
            script_name: script_name,
            script_api_type: script_api_type,
            language: language,
            config_ui: config_ui
          )
        end

        def update_env(**args)
          capture_io do
            args.slice(*MUTABLE_ENV_VALUES).each do |key, value|
              project.env.extra[key.to_s.upcase] = value
              project.env.update(ctx, :extra, project.env.extra)
            end
          end

          Domain::ScriptProject.new(
            id: ctx.root,
            env: project.env,
            script_name: script_name,
            script_api_type: script_api_type,
            language: language,
            config_ui: ConfigUiRepository.new(ctx: ctx).get(config_ui_file),
          )
        end

        def create_env(api_key:, secret:, uuid:)
          ShopifyCli::Resources::EnvFile.new(
            api_key: api_key,
            secret: secret,
            extra: {
              Domain::ScriptProject::UUID_ENV_KEY => uuid,
            }
          ).write(ctx)

          Domain::ScriptProject.new(
            id: ctx.root,
            env: project.env,
            script_name: script_name,
            script_api_type: script_api_type,
            language: language,
            config_ui: ConfigUiRepository.new(ctx: ctx).get(config_ui_file),
          )
        end

        private

        def capture_io(&block)
          CLI::UI::StdoutRouter::Capture.new(&block).run
        end

        def script_api_type
          project_config_value!("script_api_type") || project_config_value!("extension_point_type")
        end

        def script_name
          project_config_value!("script_name")
        end

        def config_ui_file
          project_config_value("config_ui_file")
        end

        def language
          project_config_value("language")&.downcase || default_language
        end

        def project_config_value(key)
          return nil unless project.config.key?(key)
          project.config[key]
        end

        def project_config_value!(key)
          raise Errors::InvalidContextError, key unless project.config.key?(key)
          project.config[key]
        end

        def project
          @project ||= ShopifyCli::Project.current(force_reload: true)
        end

        def default_language
          Domain::ScriptApi::ScriptApiAssemblyScriptSDK.language
        end

        def validate_metadata!(script_api_type, language)
          if Application::ScriptApis.deprecated_types.include?(script_api_type)
            raise Errors::DeprecatedEPError, script_api_type
          elsif !Application::ScriptApis.supported_language?(type: script_api_type, language: language)
            raise Errors::InvalidLanguageError.new(language, script_api_type)
          end
        end

        class ConfigUiRepository
          include SmartProperties
          property! :ctx, accepts: ShopifyCli::Context

          def get(filename)
            return nil unless filename

            path = File.join(ctx.root, filename)
            raise Domain::Errors::MissingSpecifiedConfigUiDefinitionError, filename unless File.exist?(path)

            content = File.read(path)
            raise Domain::Errors::InvalidConfigUiDefinitionError, filename unless valid_config_ui?(content)

            Domain::ConfigUi.new(
              filename: filename,
              content: content,
            )
          end

          private

          def valid_config_ui?(raw_yaml)
            require "yaml" # takes 20ms, so deferred as late as possible.
            YAML.safe_load(raw_yaml)
            true
          rescue Psych::SyntaxError
            false
          end
        end
      end
    end
  end
end
