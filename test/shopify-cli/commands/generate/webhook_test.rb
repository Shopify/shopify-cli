require 'test_helper'

module ShopifyCli
  module Commands
    class Generate
      class WebhookTest < MiniTest::Test
        include TestHelpers::Project

        def setup
          super
          @command = ShopifyCli::Commands::Generate.new(@context)
        end

        def test_with_param
          ShopifyCli::Tasks::Schema.expects(:call).returns(
            JSON.parse(File.read(File.join(ShopifyCli::ROOT, "test/fixtures/shopify_schema.json")))
          )
          @context.expects(:system).with('a command')
            .returns(mock(success?: true))
          @command.call(['webhook', 'PRODUCT_CREATE'], nil)
        end

        def test_with_selection
          ShopifyCli::Tasks::Schema.expects(:call).returns(
            JSON.parse(File.read(File.join(ShopifyCli::ROOT, "test/fixtures/shopify_schema.json"))),
          )
          CLI::UI::Prompt.expects(:ask).returns('PRODUCT_CREATE')
          @context.expects(:system).with('a command')
            .returns(mock(success?: true))
          @command.call(['webhook'], nil)
        end
      end
    end
  end
end
