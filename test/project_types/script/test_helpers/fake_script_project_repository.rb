# frozen_string_literal: true

module TestHelpers
  class FakeScriptProjectRepository
    attr_reader :ctx, :initial_directory

    def initialize(
      ctx = TestHelpers::FakeContext.new,
      directory = "fake_directory",
      initial_directory = ctx.root
    )
      @ctx = ctx
      @directory = directory
      @initial_directory = initial_directory
      @project = nil
    end

    def create(script_name:, extension_point_type:, language:, env: nil)
      script_config = fake_script_config_repo.create({ "version" => 1, "title" => script_name })

      @project = Script::Layers::Domain::ScriptProject.new(
        id: "/#{script_name}",
        env: env || ShopifyCLI::Resources::EnvFile.new(api_key: "1234", secret: "shh", extra: {}),
        script_name: script_name,
        extension_point_type: extension_point_type,
        language: language,
        script_config: script_config
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

    def update_script_config(title:)
      script_config = fake_script_config_repo
        .update!(title: title)

      @project.script_config = script_config
      @project
    end

    def create_project_directory; end
    def delete_project_directory; end
    def change_to_initial_directory; end

    private

    def fake_script_config_repo
      @fake_script_config_repo ||= FakeScriptConfigRepository.new
    end

    class FakeScriptConfigRepository
      def initialize
        @cache = nil
      end

      def create(content)
        @cache = from_h(content)
      end

      def update!(title:)
        hash = get!.content
        hash["title"] = title

        @cache = from_h(hash)
      end

      def get!
        raise Script::Layers::Infrastructure::Errors::NoScriptConfigFileError, filename if @cache.nil?
        @cache
      end

      def filename
        "script.config.yml"
      end

      private

      def from_h(hash)
        Script::Layers::Domain::ScriptConfig.new(content: hash, filename: filename)
      end
    end
  end
end
