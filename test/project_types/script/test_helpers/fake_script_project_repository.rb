# frozen_string_literal: true

module TestHelpers
  class FakeScriptProjectRepository
    def initialize
      @project = nil
    end

    def create(script_name:, extension_point_type:, language:, no_config_ui:, env: nil)
      config_ui_file = if no_config_ui
        nil
      else
        FakeConfigUiRepository.new.create("config-ui.yml", "---\nversion: 1")
      end

      @project = Script::Layers::Domain::ScriptProject.new(
        id: "/#{script_name}",
        env: env || ShopifyCli::Resources::EnvFile.new(api_key: "1234", secret: "shh", extra: {}),
        script_name: script_name,
        extension_point_type: extension_point_type,
        language: language,
        config_ui: config_ui_file
      )
    end

    def get
      @project
    end

    def update_env(**args)
      args.slice(*Script::Layers::Infrastructure::ScriptProjectRepository::MUTABLE_ENV_VALUES).each do |key, value|
        @project.env.extra[key.to_s.upcase] = value
      end

      @project
    end

    def create_env(api_key:, secret:, uuid:)
      @project.env = ShopifyCli::Resources::EnvFile.new(api_key: api_key, secret: secret, extra: { "UUID" => uuid })
      @project
    end

    class FakeConfigUiRepository
      def initialize
        @cache = {}
      end

      def create(filename, content)
        @cache[filename] = Script::Layers::Domain::ConfigUi.new(
          filename: filename,
          content: content,
        )
      end

      def get(filename)
        @cache[filename]
      end
    end
  end
end
