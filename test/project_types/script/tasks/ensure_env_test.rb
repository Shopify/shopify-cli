# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Tasks::EnsureEnv do
  include TestHelpers::FakeFS

  describe ".call" do
    let(:context) { TestHelpers::FakeContext.new(root: Dir.mktmpdir) }
    let(:language) { "assemblyscript" }
    let(:extension_point_type) { "discount" }
    let(:script_name) { "name" }
    let(:is_shopifolk) { false }
    let(:script_project_repository) { TestHelpers::FakeScriptProjectRepository.new }

    subject do
      Script::Tasks::EnsureEnv.call(context)
    end

    before do
      context.output_captured = true
      ShopifyCli::Shopifolk.stubs(:check).returns(is_shopifolk)
      Script::Layers::Infrastructure::ScriptProjectRepository.stubs(:new).returns(script_project_repository)
      script_project_repository.create(
        language: language,
        extension_point_type: extension_point_type,
        script_name: script_name,
        no_config_ui: false,
        env: env
      )
    end

    describe "when env already has all required fields" do
      let(:env) { ShopifyCli::Resources::EnvFile.new(api_key: "api_key", secret: "shh", extra: { "UUID" => "uuid" }) }

      it "does nothing" do
        CLI::UI::Prompt.expects(:ask).never
        CLI::UI::Prompt.expects(:confirm).never
        ShopifyCli::PartnersAPI.expects(:query).never
        Script::Layers::Infrastructure::ScriptService.any_instance.expects(:get_app_scripts).never

        assert_nil subject
      end
    end

    describe "when env is not yet valid" do
      def new_app(title, api_key, secret)
        {
          "title" => title,
          "apiKey" => api_key,
          "apiSecretKeys" => [{ "secret" => secret }],
        }
      end

      def new_org(id, name)
        {
          "id" => id,
          "businessName" => name,
        }
      end

      def expect_new_env
        assert_equal selected_api_key, subject.env.api_key
        assert_equal selected_secret, subject.env.secret

        if selected_uuid.nil?
          assert_nil subject.env.extra["UUID"]
        else
          assert_equal selected_uuid, subject.env.extra["UUID"]
        end
      end

      def self.it_prompts_user_and_update_env
        let(:orgs) { [new_org(1, "business1")] }
        let(:apps) { [new_app("app1", selected_api_key, selected_secret)] }
        let(:existing_scripts) { [] }
        let(:orgs_with_apps) do
          orgs.map do |org|
            org.merge({ "apps" => apps })
          end
        end
        let(:selected_org) { orgs_with_apps.first }
        let(:selected_api_key) { "default_api_key" }
        let(:selected_secret) { "default_secret" }
        let(:selected_uuid) { nil }

        before do
          ShopifyCli::PartnersAPI::Organizations
            .stubs(:fetch_with_app)
            .returns(orgs_with_apps)
          Script::Layers::Infrastructure::ScriptService
            .any_instance
            .stubs(:get_app_scripts)
            .with(api_key: selected_api_key, extension_point_type: extension_point_type)
            .returns(existing_scripts)
        end

        describe("when asking org") do
          describe("when number of orgs == 0") do
            let(:orgs) { [] }

            it("raises NoExistingOrganizationsError") do
              assert_raises(Script::Errors::NoExistingOrganizationsError) { subject }
            end
          end

          describe("when number of orgs == 1") do
            let(:orgs) { [new_org(1, "business1")] }
            let(:selected_org) { orgs_with_apps.first }

            it("selects the org by default") do
              assert_equal selected_api_key, subject.env.api_key
              assert_equal selected_secret, subject.env.secret
              assert_nil subject.env.extra["UUID"]
            end
          end

          describe("when number of orgs > 1") do
            let(:orgs) { [new_org(1, "business1"), new_org(2, "business2")] }
            let(:selected_org) { orgs_with_apps.last }

            it("prompts to select an org") do
              CLI::UI::Prompt
                .expects(:ask)
                .with(context.message("script.application.ensure_env.organization_select"))
                .returns(selected_org)

              expect_new_env
            end
          end
        end

        describe("when asking app connection") do
          describe("when number of apps == 0") do
            let(:apps) { [] }

            it("raises NoExistingAppsError") do
              assert_raises(Script::Errors::NoExistingAppsError) { subject }
            end
          end

          describe("when number of apps == 1") do
            let(:apps) { [new_app("app1", selected_api_key, selected_secret)] }
            let(:selected_api_key) { "selected_api_key" }
            let(:selected_secret) { "selected_secret" }

            it("selects the app by default") do
              expect_new_env
            end
          end

          describe("when number of apps > 1") do
            let(:apps) { [new_app("app1", "1", "1"), new_app("app2", selected_api_key, selected_secret)] }
            let(:selected_api_key) { "selected_api_key" }
            let(:selected_secret) { "selected_secret" }

            it("prompts to select an app") do
              CLI::UI::Prompt
                .expects(:ask)
                .with(context.message("script.application.ensure_env.app_select"))
                .returns(apps.last)

              expect_new_env
            end
          end
        end

        describe("when asking script connection") do
          describe("when number of scripts == 0") do
            let(:selected_uuid) { nil }

            it("should set uuid to nil") do
              expect_new_env
            end
          end

          describe("when number of scripts > 0") do
            let(:new_script_uuid) { "new_script_uuid" }
            let(:existing_scripts) { [{ "title" => "script_title", "uuid" => new_script_uuid }] }

            describe("when user wants to connect to script") do
              let(:selected_uuid) { new_script_uuid }

              it("should set uuid to the uuid of that script") do
                CLI::UI::Prompt
                  .expects(:confirm)
                  .with(context.message("script.application.ensure_env.ask_connect_to_existing_script"))
                  .returns(true)

                CLI::UI::Prompt
                  .expects(:ask)
                  .with(context.message("script.application.ensure_env.ask_which_script_to_connect_to"))
                  .returns(selected_uuid)

                expect_new_env
              end
            end

            describe("when user does not want to connect to script") do
              let(:selected_uuid) { nil }

              it("should set uuid to nil") do
                CLI::UI::Prompt
                  .expects(:confirm)
                  .with(context.message("script.application.ensure_env.ask_connect_to_existing_script"))
                  .returns(false)

                CLI::UI::Prompt
                  .expects(:ask)
                  .with(context.message("script.application.ensure_env.ask_which_script_to_connect_to"))
                  .never

                expect_new_env
              end
            end
          end
        end
      end

      describe "when env is empty" do
        let(:env) { nil }

        it_prompts_user_and_update_env
      end

      describe "when missing uuid" do
        let(:env) { ShopifyCli::Resources::EnvFile.new(api_key: "api_key", secret: "shh") }

        it_prompts_user_and_update_env
      end
    end
  end
end
