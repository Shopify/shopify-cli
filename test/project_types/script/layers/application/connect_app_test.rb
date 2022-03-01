# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Application::ConnectApp do
  let(:context) { TestHelpers::FakeContext.new(root: Dir.mktmpdir) }
  let(:title) { "title" }
  let(:language) { "typescript" }
  let(:extension_point_type) { "payment-methods" }

  let(:script_project_repository) { TestHelpers::FakeScriptProjectRepository.new }

  before do
    Script::Layers::Infrastructure::ScriptProjectRepository.stubs(:new).returns(script_project_repository)
    Script::Layers::Infrastructure::ScriptProjectRepository.any_instance.stubs(:get).returns(script_project)
  end

  describe ".call" do
    subject do
      Script::Layers::Application::ConnectApp.call(ctx: context)
    end

    describe "when script project env is valid" do
      let(:script_project) do
        script_project_repository.create(
          language: language,
          extension_point_type: extension_point_type,
          title: title,
          env: ShopifyCLI::Resources::EnvFile.new(
            api_key: "api_key",
            secret: "secret",
            extra: { "UUID" => "uuid" }
          )
        )
      end

      it "should return false and not prompt" do
        Script::Forms::RunAgainstShopifyOrg.expects(:ask).never
        ShopifyCLI::Shopifolk.expects(:check).never
        refute subject
      end
    end

    describe "when script project env is not valid" do
      def new_app(title, api_key, secret, app_type = "custom")
        {
          "title" => title,
          "apiKey" => api_key,
          "apiSecretKeys" => [{ "secret" => secret }],
          "appType" => app_type,
        }
      end

      def new_org(id, name)
        {
          "id" => id,
          "businessName" => name,
        }
      end

      let(:orgs) do
        [
          new_org(1, "business1"),
          new_org(2, "business2"),
        ]
      end

      let(:selected_api_key) { "default_api_key" }
      let(:selected_secret) { "default_secret" }
      let(:apps) do
        [
          new_app("app1", selected_api_key, selected_secret),
          new_app("app2", selected_api_key, selected_secret),
        ]
      end

      let(:script_project) do
        script_project_repository.create(
          language: language,
          extension_point_type: extension_point_type,
          title: title,
          env: ShopifyCLI::Resources::EnvFile.new(
            api_key: selected_api_key,
            secret: selected_secret,
            # intentionally missing UUID
          )
        )
      end

      before do
        ShopifyCLI::Shopifolk.stubs(check: false)
        Script::Forms::RunAgainstShopifyOrg.stubs(:ask).returns(stub(response: false))

        orgs_with_apps = orgs.map do |org|
          org.merge({ "apps" => apps })
        end
        ShopifyCLI::PartnersAPI::Organizations
          .stubs(:fetch_with_app)
          .returns(orgs_with_apps)

        selected_org = orgs_with_apps.first
        Script::Forms::AskOrg.stubs(:ask).returns(stub(org: selected_org))

        selected_app = selected_org["apps"].first
        Script::Forms::AskApp.stubs(:ask).returns(stub(app: selected_app))

        existing_scripts = []
        Script::Layers::Infrastructure::ScriptService
          .any_instance
          .stubs(:get_app_scripts)
          .with(extension_point_type: extension_point_type)
          .returns(existing_scripts)
      end

      it "should connect by calling create_env on script_project_repo" do
        selected_uuid = nil
        script_project_repository
          .expects(:create_env)
          .with(
            api_key: selected_api_key,
            secret: selected_secret,
            uuid: selected_uuid
          )
        assert subject
      end
    end
  end
end
