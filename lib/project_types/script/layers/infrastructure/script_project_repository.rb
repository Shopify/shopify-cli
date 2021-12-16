# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class ScriptProjectRepository
        include SmartProperties
        property! :ctx, accepts: ShopifyCLI::Context
        property! :directory, accepts: String
        property! :initial_directory, accepts: String

        MUTABLE_ENV_VALUES = %i(uuid)

        def create_project_directory
          raise Infrastructure::Errors::ScriptProjectAlreadyExistsError, directory if ctx.dir_exist?(directory)
          ctx.mkdir_p(directory)
          change_directory(directory: directory)
        end

        def delete_project_directory
          change_to_initial_directory
          ctx.rm_r(directory)
        end

        def change_to_initial_directory
          change_directory(directory: initial_directory)
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

        def update_script_config(title:)
          script_config = script_config_repository.update!(title: title)

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

        def change_directory(directory:)
          ctx.chdir(directory)
        end

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
          @script_config_repository ||= begin
            supported_repos = [
              ScriptConfigYmlRepository.new(ctx: ctx),
              ScriptJsonRepository.new(ctx: ctx),
            ]
            repo = supported_repos.find(&:active?)
            raise Infrastructure::Errors::NoScriptConfigYmlFileError if repo.nil?
            repo
          end
        end

        class ScriptConfigRepository
          include SmartProperties
          property! :ctx, accepts: ShopifyCLI::Context

          def active?
            ctx.file_exist?(filename)
          end

          def get!
            raise Infrastructure::Errors::NoScriptConfigFileError unless active?

            content = ctx.read(filename)
            hash = file_content_to_hash(content)

            from_h(hash)
          end

          def update!(title:)
            hash = get!.content
            update_hash(hash: hash, title: title)

            ctx.write(filename, hash_to_file_content(hash))

            from_h(hash)
          end

          private

          def update_hash(hash:, title:)
            hash["version"] ||= "2"
            hash["title"] = title
          end

          def from_h(hash)
            Domain::ScriptConfig.new(content: hash)
          rescue Domain::Errors::MissingScriptConfigFieldError => e
            raise missing_field_error, e.field
          end

          # to be implemented by subclasses
          def filename
            raise NotImplementedError
          end

          def file_content_to_hash(file_content)
            raise NotImplementedError
          end

          def hash_to_file_content(hash)
            raise NotImplementedError
          end

          def missing_field_error
            raise NotImplementedError
          end
        end

        class ScriptConfigYmlRepository < ScriptConfigRepository
          private

          def filename
            "script.config.yml"
          end

          def file_content_to_hash(file_content)
            begin
              hash = YAML.load(file_content)
            rescue Psych::SyntaxError
              raise Errors::InvalidScriptConfigYmlDefinitionError
            end
            raise Errors::InvalidScriptConfigYmlDefinitionError unless hash.is_a?(Hash)
            hash
          end

          def hash_to_file_content(hash)
            YAML.dump(hash)
          end

          def missing_field_error
            Errors::MissingScriptConfigYmlFieldError
          end
        end

        class ScriptJsonRepository < ScriptConfigRepository
          private

          def filename
            "script.json"
          end

          def file_content_to_hash(file_content)
            JSON.parse(file_content)
          rescue JSON::ParserError
            raise Errors::InvalidScriptJsonDefinitionError
          end

          def hash_to_file_content(hash)
            JSON.pretty_generate(hash)
          end

          def missing_field_error
            Errors::MissingScriptJsonFieldError
          end
        end
      end
    end
  end
end
