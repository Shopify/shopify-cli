# frozen_string_literal: true

module TestHelpers
  class FakeScriptProjectRepository
    def initialize
      @project = nil
    end

    def create(script_name:, extension_point_type:, language:, env: nil)
      script_json = fake_script_json_repo.create({ version: 1, title: script_name }.to_json)

      @project = Script::Layers::Domain::ScriptProject.new(
        id: "/#{script_name}",
        env: env || ShopifyCLI::Resources::EnvFile.new(api_key: "1234", secret: "shh", extra: {}),
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
      @project.env = ShopifyCLI::Resources::EnvFile.new(api_key: api_key, secret: secret, extra: { "UUID" => uuid })
      @project
    end

    def update_or_create_script_json(title:, configuration_ui: false)
      script_json = fake_script_json_repo
        .update_or_create(title: title, configuration_ui: configuration_ui)

      @project.script_json = script_json
      @project
    end

    private

    def fake_script_json_repo
      @fake_script_json_repo ||= FakeScriptJsonRepository.new
    end

    class FakeScriptJsonRepository
      def initialize
        @cache = nil
      end

      def create(content)
        @cache = Script::Layers::Domain::ScriptJson.new(
          content: JSON.parse(content),
        )
      end

      def update_or_create(title:, configuration_ui:)
        json = @cache&.content || {}
        json["title"] = title
        json["configurationUi"] = !!configuration_ui

        @cache = Script::Layers::Domain::ScriptJson.new(
          content: json,
        )
      end

      def get
        @cache
      end
    end
  end
end
