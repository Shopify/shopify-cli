# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Forms::AskApp do
  include TestHelpers::FakeFS
  describe ".ask" do
    let(:context) { TestHelpers::FakeContext.new(root: Dir.mktmpdir) }
    let(:acting_as_shopify_organization) { false }
    let(:selected_api_key) { "default_api_key" }
    let(:selected_secret) { "default_secret" }

    subject do
      result = nil
      capture_io do
        result = Script::Forms::AskApp.ask(
          context,
          {
            apps: apps,
            acting_as_shopify_organization: acting_as_shopify_organization,
          },
          {}
        )
      end
      result
    end

    def new_app(title, api_key, secret, app_type = "custom")
      {
        "title" => title,
        "apiKey" => api_key,
        "apiSecretKeys" => [{ "secret" => secret }],
        "appType" => app_type,
      }
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

        it("selects the app by default") do
          selected_app_msg = context.message("script.application.ensure_env.app", app_title)
          context.expects(:puts).with(selected_app_msg)

          assert_equal apps.first, subject.app
        end
      end

      describe("when number of apps > 1") do
        let(:apps) { [new_app("app1", "1", "1"), new_app("app2", selected_api_key, selected_secret)] }

        it("prompts to select an app") do
          CLI::UI::Prompt
            .expects(:ask)
            .with(context.message("script.application.ensure_env.app_select"))
            .returns(apps.last)

          assert_equal apps.last, subject.app
        end
      end
    end
  end
end
