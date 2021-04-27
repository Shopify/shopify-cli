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
        env: env || ShopifyCli::Resources::EnvFile.new(api_key: "1234", secret: "shh"),
        script_name: script_name,
        extension_point_type: extension_point_type,
        language: language,
        config_ui: config_ui_file
      )
    end

    def get
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
