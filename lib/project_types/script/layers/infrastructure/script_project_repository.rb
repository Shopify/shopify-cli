# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class ScriptProjectRepository
        include SmartProperties
        property! :ctx, accepts: ShopifyCLI::Context
        property :directory, accepts: String
        property :initial_directory, accepts: String

        MUTABLE_ENV_VALUES = %i(uuid)
        INPUT_QUERY_PATH = "input.graphql"

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

        def create(title:, extension_point_type:, language:)
          validate_metadata!(extension_point_type, language)

          ShopifyCLI::Project.write(
            ctx,
            project_type: :script,
            organization_id: nil,
            extension_point_type: extension_point_type,
            title: title,
            description: nil,
            language: language
          )

          build_script_project(script_config: nil)
        end

        def get
          validate_metadata!(extension_point_type, language)

          Domain::ScriptProject.new(
            id: project.directory,
            env: project.env,
            title: title,
            description: description,
            extension_point_type: extension_point_type,
            language: language,
            script_config: script_config_repository.get!,
            input_query: read_input_query,
          )
        end

        def update_env(**args)
          capture_io do
            args.slice(*MUTABLE_ENV_VALUES).each do |key, value|
              project.env.extra[key.to_s.upcase] = value
              project.env.update(ctx, :extra, project.env.extra)
            end
          end

          build_script_project
        end

        def create_env(api_key:, secret:, uuid:)
          ShopifyCLI::Resources::EnvFile.new(
            api_key: api_key,
            secret: secret,
            extra: {
              Domain::ScriptProject::UUID_ENV_KEY => uuid,
            }
          ).write(ctx)

          build_script_project
        end

        private

        def build_script_project(
          script_config: script_config_repository.get!
        )
          Domain::ScriptProject.new(
            id: ctx.root,
            env: project.env,
            title: title,
            description: description,
            extension_point_type: extension_point_type,
            language: language,
            script_config: script_config,
          )
        end

        def change_directory(directory:)
          ctx.chdir(directory)
        end

        def capture_io(&block)
          CLI::UI::StdoutRouter::Capture.new(&block).run
        end

        def extension_point_type
          project_config_value!("extension_point_type")
        end

        def title
          project_config_value!("title")
        end

        def description
          project_config_value("description")
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
          "wasm"
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
            script_config_yml_repo = ScriptConfigYmlRepository.new(ctx: ctx)
            supported_repos = [
              script_config_yml_repo,
              ScriptJsonRepository.new(ctx: ctx),
            ]
            repo = supported_repos.find(&:active?)
            if repo.nil?
              raise Infrastructure::Errors::NoScriptConfigFileError, script_config_yml_repo.filename
            end
            repo
          end
        end

        def read_input_query
          ctx.read(INPUT_QUERY_PATH) if ctx.file_exist?(INPUT_QUERY_PATH)
        end

        class ScriptConfigRepository
          include SmartProperties
          property! :ctx, accepts: ShopifyCLI::Context

          def active?
            ctx.file_exist?(filename)
          end

          def get!
            raise Infrastructure::Errors::NoScriptConfigFileError, filename unless active?

            content = ctx.read(filename)
            hash = file_content_to_hash(content)

            from_h(hash)
          end

          def filename
            raise NotImplementedError
          end

          private

          def from_h(hash)
            Domain::ScriptConfig.new(content: hash, filename: filename)
          end

          def file_content_to_hash(file_content)
            raise NotImplementedError
          end

          def hash_to_file_content(hash)
            raise NotImplementedError
          end
        end

        class ScriptConfigYmlRepository < ScriptConfigRepository
          def filename
            "script.config.yml"
          end

          private

          def file_content_to_hash(file_content)
            begin
              hash = YAML.load(file_content)
            rescue Psych::SyntaxError
              raise parse_error
            end
            raise parse_error unless hash.is_a?(Hash)
            hash
          end

          def hash_to_file_content(hash)
            YAML.dump(hash)
          end

          def parse_error
            Errors::ScriptConfigParseError.new(filename: filename, serialization_format: "YAML")
          end
        end

        class ScriptJsonRepository < ScriptConfigRepository
          def filename
            "script.json"
          end

          private

          def file_content_to_hash(file_content)
            begin
              hash = JSON.parse(file_content)
            rescue JSON::ParserError
              raise parse_error
            end
            raise parse_error unless hash.is_a?(Hash)
            hash
          end

          def hash_to_file_content(hash)
            JSON.pretty_generate(hash)
          end

          def parse_error
            Errors::ScriptConfigParseError.new(filename: filename, serialization_format: "JSON")
          end
        end
      end
    end
  end
end
