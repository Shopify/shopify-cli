# frozen_string_literal: true
require "project_types/rails/test_helper"

module Rails
  module Commands
    module GenerateTests
      class WebhookTest < MiniTest::Test
        include TestHelpers::FakeUI
        include TestHelpers::Schema

        def test_with_existing_param
          @context.expects(:system).with(generate_command("app/uninstalled")).returns(mock(success?: true))
          Rails::Command::Generate::Webhook.start(@context, ["APP_UNINSTALLED"])
        end

        def test_with_incorrect_param_expects_ask
          CLI::UI::Prompt.expects(:ask).returns("APP_UNINSTALLED")
          @context.expects(:system).with(generate_command("app/uninstalled")).returns(mock(success?: true))
          Rails::Command::Generate::Webhook.start(@context, ["create_webhook_fake"])
        end

        def test_with_selection
          CLI::UI::Prompt.expects(:ask).returns("PRODUCT_CREATE")
          @context.expects(:system).with(generate_command("product/create")).returns(mock(success?: true))
          Rails::Command::Generate::Webhook.start(@context, [])
        end

        private

        def generate_command(type)
          "bin/rails g shopify_app:add_webhook -t #{type} -a https://example.com/webhooks/#{type}"
        end
      end
    end
  end
end
