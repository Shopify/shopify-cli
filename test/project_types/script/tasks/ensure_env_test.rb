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
      result = nil
      capture_io { result = Script::Tasks::EnsureEnv.call(context) }
      result
    end

    before do
      context.output_captured = true
      ShopifyCLI::Shopifolk.stubs(:check).returns(is_shopifolk)
      ShopifyCLI::Shopifolk.stubs(:acting_as_shopify_organization?).returns(false)
      Script::Layers::Infrastructure::ScriptProjectRepository.stubs(:new).returns(script_project_repository)
      script_project_repository.create(
        language: language,
        extension_point_type: extension_point_type,
        script_name: script_name,
        env: env
      )
    end

    describe "when env already has all required fields" do
      let(:env) { ShopifyCLI::Resources::EnvFile.new(api_key: "api_key", secret: "shh", extra: { "UUID" => "uuid" }) }

      it "does nothing" do
        CLI::UI::Prompt.expects(:ask).never
        CLI::UI::Prompt.expects(:confirm).never
        ShopifyCLI::PartnersAPI.expects(:query).never
        Script::Layers::Infrastructure::ScriptService.any_instance.expects(:get_app_scripts).never

        refute subject
      end
    end

    describe "when env is not yet valid" do
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

      def expect_new_env
        assert subject

        project = script_project_repository.get
        assert_equal selected_api_key, project.env.api_key
        assert_equal selected_secret, project.env.secret

        if selected_uuid.nil?
          assert_nil project.env.extra["UUID"]
        else
          assert_equal selected_uuid, project.env.extra["UUID"]
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
          ShopifyCLI::PartnersAPI::Organizations
            .stubs(:fetch_with_app)
            .returns(orgs_with_apps)
          Script::Layers::Infrastructure::ScriptService
            .any_instance
            .stubs(:get_app_scripts)
            .with(extension_point_type: extension_point_type)
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
            let(:org_id) { 1 }
            let(:org_name) { "business1" }
            let(:orgs) { [new_org(org_id, org_name)] }
            let(:selected_org) { orgs_with_apps.first }

            it("selects the org by default") do
              selected_org_msg = context.message("script.application.ensure_env.organization", org_name, org_id)
              context.expects(:puts).with(selected_org_msg)
              context.stubs(:puts).with(Not(equals(selected_org_msg)))

              assert subject
              project = script_project_repository.get
              assert_equal selected_api_key, project.env.api_key
              assert_equal selected_secret, project.env.secret
              assert_nil project.env.extra["UUID"]
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

        describe("when the partners bypass flag is set") do
          before do
            Script::Tasks::EnsureEnv.any_instance.stubs(:partner_proxy_bypass).returns(true)
          end

          it("should not call partners to query for apps") do
            ShopifyCLI::PartnersAPI.expects(:query).never
            Script::Layers::Infrastructure::ScriptService.any_instance.expects(:get_app_scripts).returns([])

            subject
          end
        end

        describe("when asking app connection") do
          describe("when number of apps == 0") do
            let(:apps) { [] }

            it("raises NoExistingAppsError") do
              assert_raises(Script::Errors::NoExistingAppsError) { subject }
            end
          end

          describe("when there is 1 public app") do
            let(:apps) { new_app("app1", "1", "1", "public") }

            it("raises NoExistingAppsError") do
              assert_raises(Script::Errors::NoExistingAppsError) { subject }
            end
          end

          describe("when number of apps == 1") do
            let(:app_title) { "app1" }
            let(:apps) { [new_app("app1", selected_api_key, selected_secret)] }
            let(:selected_api_key) { "selected_api_key" }
            let(:selected_secret) { "selected_secret" }

            it("selects the app by default") do
              selected_app_msg = context.message("script.application.ensure_env.app", app_title)
              context.expects(:puts).with(selected_app_msg)
              context.stubs(:puts).with(Not(equals(selected_app_msg)))

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
        let(:env) { ShopifyCLI::Resources::EnvFile.new(api_key: "api_key", secret: "shh") }

        it_prompts_user_and_update_env
      end
    end
  end
end
