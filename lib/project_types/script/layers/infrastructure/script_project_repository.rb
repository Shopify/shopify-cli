# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class ScriptProjectRepository
        include SmartProperties
        property! :ctx, accepts: ShopifyCli::Context

        DEFAULT_CONFIG_UI_FILENAME = "config-ui.yml"

        def create(script_name:, extension_point_type:, language:, no_config_ui:)
          # TODO: move all errors into infra layer
          raise Errors::ScriptProjectAlreadyExistsError, script_name if ctx.dir_exist?(script_name)
          ctx.mkdir_p(script_name)
          ctx.chdir(script_name)

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
            env: current_project.env,
            script_name: script_name,
            extension_point_type: extension_point_type,
            language: language,
            config_ui: config_ui_file
          )
        end

        def delete
          return nil unless current_project_exists?

          script_name = project_config_value!("script_name")
          root_dir = File.join(current_project.directory, "../")
          ctx.chdir(root_dir)
          ctx.rm_r("#{root_dir}/#{script_name}")
        end

        def get
          extension_point_type = project_config_value!("extension_point_type")
          script_name = project_config_value!("script_name")
          config_ui_file = project_config_value("config_ui_file")
          language = project_config_value("language")&.downcase || default_language

          if deprecated_extension_point?(extension_point_type)
            raise Errors::DeprecatedEPError, extension_point_type
          elsif !supported_language?(extension_point_type, language)
            raise Errors::InvalidLanguageError.new(language, extension_point_type)
          end

          # TODO: remove this repo and make it an implementation detail
          config_ui = Infrastructure::ConfigUiRepository.new(ctx: ctx).get_config_ui(config_ui_file)

          Domain::ScriptProject.new(
            id: current_project.directory,
            env: current_project.env,
            script_name: script_name,
            extension_point_type: extension_point_type,
            language: language,
            config_ui: config_ui
          )
        end

        private

        def project_config_value(key)
          return nil unless current_project.config.key?(key)
          current_project.config[key]
        end

        def project_config_value!(key)
          raise Errors::InvalidContextError, key unless current_project.config.key?(key)
          current_project.config[key]
        end

        def current_project_exists?
          ShopifyCli::Project.has_current?
        end

        def current_project
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

        def deprecated_extension_point?(extension_point_type)
          Application::ExtensionPoints.deprecated_types.include?(extension_point_type)
        end

        def supported_language?(extension_point_type, language)
          Application::ExtensionPoints.supported_language?(type: extension_point_type, language: language)
        end

        def default_language
          Domain::ExtensionPoint::ExtensionPointAssemblyScriptSDK.language
        end

        # TODO: call this somewhere
        def monorail_metadata
          ShopifyCli::Core::Monorail.metadata = {
            "script_name" => @script_name,
            "extension_point_type" => @extension_point_type,
            "language" => @language,
          }
        end
      end
    end
  end
end
