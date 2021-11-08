# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Application::ConnectApp do
  let(:script_name) { "script_name" }
  let(:language) { "typescript" }
  let(:extension_point_type) { "payment-methods" }

  let(:script_project_repository) { TestHelpers::FakeScriptProjectRepository.new }
  let(:script_project) do
    script_project_repository.create(
      language: language,
      extension_point_type: extension_point_type,
      script_name: script_name,
      env: env
    )
  end

  let(:app) do
    {
      "title" => "app_title",
      "apiKey" => "api_key",
      "apiSecretKeys" => [{ "secret" => "shh" }],
      "appType" => "custom",
    }
  end
  let(:api_key) { "apikey" }
  let(:secret) { "shh" }
  let(:uuid) { "uuid" }

  before do
    Script::Layers::Infrastructure::ScriptProjectRepository.stubs(:new).returns(script_project_repository)
  end

  describe ".call" do
    subject do
      Script::Layers::Application::ConnectApp.call(
        script_project_repo: script_project_repository,
        api_key: api_key,
        secret: secret,
        uuid: uuid,
      )
    end

    it "should connect by calling create_env on script_project_repo" do
      script_project_repository
        .expects(:create_env)
        .with(
          api_key: api_key,
          secret: secret,
          uuid: uuid
        )
      subject
    end
  end

  describe ".env_valid?" do
    subject do
      Script::Layers::Application::ConnectApp.env_valid?(
        script_project: script_project,
      )
    end

    describe "when env already has all required fields" do
      let(:env) do
        ShopifyCLI::Resources::EnvFile.new(
          api_key: api_key,
          secret: secret,
          extra: { "UUID" => uuid }
        )
      end

      it "returns true" do
        assert subject
      end
    end

    describe "when env is missing uuid" do
      let(:env) do
        ShopifyCLI::Resources::EnvFile.new(
          api_key: api_key,
          secret: secret,
        )
      end

      it "returns false" do
        refute subject
      end
    end

    describe "when env is nil" do
      let(:env) { nil }

      it "returns false" do
        refute subject
      end
    end
  end
end
