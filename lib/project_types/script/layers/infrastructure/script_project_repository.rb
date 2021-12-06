# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class ScriptProjectRepository
        include SmartProperties
        property! :ctx, accepts: ShopifyCLI::Context

        MUTABLE_ENV_VALUES = %i(uuid)

        def create(script_name:, extension_point_type:, language:)
          validate_metadata!(extension_point_type, language)

          ShopifyCLI::Project.write(
            ctx,
            project_type: :script,
            organization_id: nil,
            extension_point_type: extension_point_type,
            script_name: script_name,
            language: language
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
            script_config: script_config_repository.get!
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
            script_config: script_config_repository.get!,
          )
        end

        def create_env(api_key:, secret:, uuid:)
          ShopifyCLI::Resources::EnvFile.new(
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
            script_config: script_config_repository.get!,
          )
        end

        def update_or_create_script_config(title:)
          script_config = script_config_repository.update_or_create(title: title)

          Domain::ScriptProject.new(
            id: ctx.root,
            env: project.env,
            script_name: script_name,
            extension_point_type: extension_point_type,
            language: language,
            script_config: script_config,
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
          @project ||= ShopifyCLI::Project.current(force_reload: true)
        end

        def default_language
          "assemblyscript"
        end

        def validate_metadata!(extension_point_type, language)
          if Application::ExtensionPoints.deprecated_types.include?(extension_point_type)
            raise Errors::DeprecatedEPError, extension_point_type
          elsif !Application::ExtensionPoints.supported_language?(type: extension_point_type, language: language)
            raise Errors::InvalidLanguageError.new(language, extension_point_type)
          end
        end

        def script_config_repository
          @script_config_repository ||= ScriptConfigRepository.new(ctx: ctx)
        end

        class ScriptConfigRepository
          include SmartProperties
          property! :ctx, accepts: ShopifyCLI::Context

          def get!
            yml_repository.get || json_repository.get || raise(Infrastructure::Errors::NoScriptConfigYmlFileError)
          end

          def update_or_create(title:)
            json_repository.update(title: title) || yml_repository.update_or_create(title: title)
          end

          private

          def yml_repository
            @yml_repository ||= ScriptConfigYmlRepository.new(ctx: ctx)
          end

          def json_repository
            @json_repository ||= ScriptJsonRepository.new(ctx: ctx)
          end
        end

        class ScriptConfigYmlRepository
          include SmartProperties
          property! :ctx, accepts: ShopifyCLI::Context

          SCRIPT_CONFIG_YML_FILENAME = "script.config.yml"

          def get
            return nil unless ctx.file_exist?(SCRIPT_CONFIG_YML_FILENAME)

            content = ctx.read(SCRIPT_CONFIG_YML_FILENAME)
            require "yaml"
            begin
              hash = YAML.load(content)
            rescue Psych::SyntaxError => e
              raise Errors::InvalidScriptConfigYmlDefinitionError
            else
              raise Errors::InvalidScriptConfigYmlDefinitionError unless hash.is_a?(Hash)
              from_h(hash)
            end
          end

          def update_or_create(title:)
            hash = get&.content || {}
            hash["version"] ||= "1"
            hash["title"] = title

            ctx.write(SCRIPT_CONFIG_YML_FILENAME, YAML.dump(hash))

            from_h(hash)
          end

          private

          def from_h(hash)
            Domain::ScriptConfig.new(content: hash)
          rescue Domain::Errors::MissingScriptConfigFieldError => e
            raise Errors::MissingScriptConfigYmlFieldError, e.field
          end
        end

        class ScriptJsonRepository
          include SmartProperties
          property! :ctx, accepts: ShopifyCLI::Context

          SCRIPT_JSON_FILENAME = "script.json"

          def get
            return nil unless ctx.file_exist?(SCRIPT_JSON_FILENAME)

            content = ctx.read(SCRIPT_JSON_FILENAME)
            begin
              hash = JSON.parse(content)
            rescue JSON::ParserError => e
              raise Errors::InvalidScriptJsonDefinitionError
            else
              from_h(hash)
            end
          end

          def update(title:)
            existing = get
            return nil if existing.nil?
            hash = existing.content
            hash["version"] ||= "1"
            hash["title"] = title

            ctx.write(SCRIPT_JSON_FILENAME, JSON.pretty_generate(hash))

            from_h(hash)
          end

          private

          def from_h(hash)
            Domain::ScriptConfig.new(content: hash)
          rescue Domain::Errors::MissingScriptConfigFieldError => e
            raise Errors::MissingScriptJsonFieldError, e.field
          end
        end
      end
    end
  end
end
