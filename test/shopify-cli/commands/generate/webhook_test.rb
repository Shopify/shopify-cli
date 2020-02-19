require 'test_helper'

module ShopifyCli
  module Commands
    class Generate
      class WebhookTest < MiniTest::Test
        include TestHelpers::FakeUI

        def setup
          super
          Helpers::AccessToken.stubs(:read).returns('myaccesstoken')
          @cmd = ShopifyCli::Commands::Generate
          @cmd.ctx = @context
          @cmd_name = 'generate'
        end

        def test_with_existing_param
          ShopifyCli::Tasks::Schema.expects(:call).returns(
            JSON.parse(File.read(File.join(ShopifyCli::ROOT, "test/fixtures/shopify_schema.json")))
          )
          @context.expects(:system).with('a command')
            .returns(mock(success?: true))
          @cmd.call(['webhook', 'APP_UNINSTALLED'], @cmd_name)
        end

        def test_with_incorrect_param_expects_ask
          ShopifyCli::Tasks::Schema.expects(:call).returns(
            JSON.parse(File.read(File.join(ShopifyCli::ROOT, "test/fixtures/shopify_schema.json")))
          )
          CLI::UI::Prompt.expects(:ask).returns('APP_UNINSTALLED')
          @context.expects(:system).with('a command')
            .returns(mock(success?: true))
          @cmd.call(['webhook', 'create_webhook_fake'], @cmd_name)
        end

        def test_with_selection
          ShopifyCli::Tasks::Schema.expects(:call).returns(
            JSON.parse(File.read(File.join(ShopifyCli::ROOT, "test/fixtures/shopify_schema.json"))),
          )
          CLI::UI::Prompt.expects(:ask).returns('PRODUCT_CREATE')
          @context.expects(:system).with('a command')
            .returns(mock(success?: true))
          @cmd.call(['webhook'], @cmd_name)
        end
      end
    end
  end
end
