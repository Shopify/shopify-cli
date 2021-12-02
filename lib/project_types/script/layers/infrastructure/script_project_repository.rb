# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class ScriptProjectRepository
        include SmartProperties
        property! :ctx, accepts: ShopifyCLI::Context

        SCRIPT_JSON_FILENAME = "script.json"
        MUTABLE_ENV_VALUES = %i(uuid)

        def self.create_project_directory(ctx:, directory:)
          raise Infrastructure::Errors::ScriptProjectAlreadyExistsError, directory if ctx.dir_exist?(directory)
          ctx.mkdir_p(directory)
          change_directory(ctx: ctx, directory: directory)
        end

        def self.delete_project_directory(ctx:, initial_directory:, directory:)
          change_directory(ctx: ctx, directory: initial_directory)
          ctx.rm_r(directory)
        end

        def self.change_directory(ctx:, directory:)
          ctx.chdir(directory)
        end

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
            script_json: ScriptJsonRepository.new(ctx: ctx).get
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
            script_json: ScriptJsonRepository.new(ctx: ctx).get,
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
            script_json: ScriptJsonRepository.new(ctx: ctx).get,
          )
        end

        def update_or_create_script_json(title:)
          script_json = ScriptJsonRepository
            .new(ctx: ctx)
            .update_or_create(title: title)

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

        class ScriptJsonRepository
          include SmartProperties
          property! :ctx, accepts: ShopifyCLI::Context

          def get
            current_script_json || raise(Domain::Errors::NoScriptJsonFile)
          end

          def update_or_create(title:)
            json = current_script_json&.content || {}
            json["version"] ||= "1"
            json["title"] = title

            ctx.write(SCRIPT_JSON_FILENAME, JSON.pretty_generate(json))

            Domain::ScriptJson.new(content: json)
          end

          private

          def current_script_json
            return nil unless ctx.file_exist?(SCRIPT_JSON_FILENAME)

            content = ctx.read(SCRIPT_JSON_FILENAME)
            raise Domain::Errors::InvalidScriptJsonDefinitionError unless valid_script_json?(content)

            Domain::ScriptJson.new(content: JSON.parse(content))
          end

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
