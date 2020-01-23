require 'test_helper'

module ShopifyCli
  module Commands
    class Generate
      class WebhookTest < MiniTest::Test
        include TestHelpers::FakeUI

        def test_with_existing_param
          ShopifyCli::Tasks::Schema.expects(:call).returns(
            JSON.parse(File.read(File.join(ShopifyCli::ROOT, "test/fixtures/shopify_schema.json")))
          )
          @context.expects(:system).with('a command')
            .returns(mock(success?: true))
          run_cmd('generate webhook APP_UNINSTALLED')
        end

        def test_with_incorrect_param_expects_ask
          ShopifyCli::Tasks::Schema.expects(:call).returns(
            JSON.parse(File.read(File.join(ShopifyCli::ROOT, "test/fixtures/shopify_schema.json")))
          )
          CLI::UI::Prompt.expects(:ask).returns('APP_UNINSTALLED')
          @context.expects(:system).with('a command')
            .returns(mock(success?: true))
          run_cmd('generate webhook create_webhook_fake')
        end

        def test_with_selection
          ShopifyCli::Tasks::Schema.expects(:call).returns(
            JSON.parse(File.read(File.join(ShopifyCli::ROOT, "test/fixtures/shopify_schema.json"))),
          )
          CLI::UI::Prompt.expects(:ask).returns('PRODUCT_CREATE')
          @context.expects(:system).with('a command')
            .returns(mock(success?: true))
          run_cmd('generate webhook')
        end
      end
    end
  end
end
