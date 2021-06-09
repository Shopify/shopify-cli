# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class ScriptProjectRepository
        include SmartProperties
        property! :ctx, accepts: ShopifyCli::Context

        DEFAULT_SCRIPT_JSON_FILENAME = "script.json"
        MUTABLE_ENV_VALUES = %i(uuid)

        def create(script_name:, extension_point_type:, language:, no_config_ui:)
          validate_metadata!(extension_point_type, language)

          optional_identifiers = {}
          optional_identifiers.merge!(script_json: DEFAULT_SCRIPT_JSON_FILENAME) unless no_config_ui

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
            language: language
          )
        end

        def get
          validate_metadata!(extension_point_type, language)

          Domain::ScriptProject.new(
            id: project.directory,
            env: project.env,
            script_name: script_name,
            extension_point_type: extension_point_type,
            language: language,
            script_json: ScriptJsonRepository.new(ctx: ctx).get(script_json_filename)
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
            extension_point_type: extension_point_type,
            language: language,
            script_json: ScriptJsonRepository.new(ctx: ctx).get(script_json_filename),
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
            extension_point_type: extension_point_type,
            language: language,
            script_json: ScriptJsonRepository.new(ctx: ctx).get(script_json_filename),
          )
        end

        def update_script_json(title:, configuration_ui: false)
          script_json = ScriptJsonRepository
            .new(ctx: ctx)
            .update(script_json_filename, title: title, configuration_ui: configuration_ui)

          Domain::ScriptProject.new(
            id: ctx.root,
            env: project.env,
            script_name: script_name,
            extension_point_type: extension_point_type,
            language: language,
            script_json: script_json,
          )
        end

        private

        def capture_io(&block)
          CLI::UI::StdoutRouter::Capture.new(&block).run
        end

        def extension_point_type
          project_config_value!("extension_point_type")
        end

        def script_name
          project_config_value!("script_name")
        end

        def script_json_filename
          project_config_value("script_json")
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
          Domain::ExtensionPoint::ExtensionPointAssemblyScriptSDK.language
        end

        def validate_metadata!(extension_point_type, language)
          if Application::ExtensionPoints.deprecated_types.include?(extension_point_type)
            raise Errors::DeprecatedEPError, extension_point_type
          elsif !Application::ExtensionPoints.supported_language?(type: extension_point_type, language: language)
            raise Errors::InvalidLanguageError.new(language, extension_point_type)
          end
        end

        class ScriptJsonRepository
          include SmartProperties
          property! :ctx, accepts: ShopifyCli::Context

          def get(filename)
            return nil unless filename

            path = File.join(ctx.root, filename)
            raise Domain::Errors::MissingSpecifiedScriptJsonDefinitionError, filename unless File.exist?(path)

            content = File.read(path)
            raise Domain::Errors::InvalidScriptJsonDefinitionError, filename unless valid_script_json?(content)

            Domain::ScriptJson.new(
              filename: filename,
              content: JSON.parse(content),
            )
          end

          def update(filename, title:, configuration_ui:)
            json = ctx.file_exist?(filename) ? JSON.parse(ctx.read(filename)) : {}
            json["title"] = title
            json["configurationUi"] = !!configuration_ui

            ctx.write(filename, JSON.pretty_generate(json))

            Domain::ScriptJson.new(
              filename: filename,
              content: json,
            )
          end

          private

          def valid_script_json?(content)
            JSON.parse(content)
            true
          rescue JSON::ParserError
            false
          end
        end
      end
    end
  end
end
