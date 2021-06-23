# frozen_string_literal: true

module TestHelpers
  class FakeScriptProjectRepository
    SCRIPT_JSON_FILENAME = Script::Layers::Infrastructure::ScriptProjectRepository::DEFAULT_SCRIPT_JSON_FILENAME

    def initialize
      @project = nil
    end

    def create(script_name:, extension_point_type:, language:, no_config_ui:, env: nil)
      _ = no_config_ui
      script_json = fake_script_json_repo.create(SCRIPT_JSON_FILENAME, { version: 1 }.to_json)

      @project = Script::Layers::Domain::ScriptProject.new(
        id: "/#{script_name}",
        env: env || ShopifyCli::Resources::EnvFile.new(api_key: "1234", secret: "shh", extra: {}),
        script_name: script_name,
        extension_point_type: extension_point_type,
        language: language,
        script_json: script_json
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

    def update_script_json(title:, configuration_ui: false)
      script_json = fake_script_json_repo
        .update(SCRIPT_JSON_FILENAME, title: title, configuration_ui: configuration_ui)

      @project.script_json = script_json
      @project
    end

    private

    def fake_script_json_repo
      @fake_script_json_repo ||= FakeScriptJsonRepository.new
    end

    class FakeScriptJsonRepository
      def initialize
        @cache = {}
      end

      def create(filename, content)
        @cache[filename] = Script::Layers::Domain::ScriptJson.new(
          filename: filename,
          content: JSON.parse(content),
        )
      end

      def update(filename, title:, configuration_ui:)
        json = @cache[filename].content || {}
        json["title"] = title
        json["configurationUi"] = !!configuration_ui

        @cache[filename] = Script::Layers::Domain::ScriptJson.new(
          filename: filename,
          content: json,
        )
      end

      def get(filename)
        @cache[filename]
      end
    end
  end
end
