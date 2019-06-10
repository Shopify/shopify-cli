require 'test_helper'

module ShopifyCli
  module Commands
    class Generate
      class WebhookTest < MiniTest::Test
        include TestHelpers::Context

        def setup
          super
          @command = ShopifyCli::Commands::Generate.new(@context)
          @responsed = '200'
        end

        def test_with_param
          ShopifyCli::Tasks::Schema.expects(:call).returns(
            JSON.parse(File.read(File.join(ShopifyCli::ROOT, "test/fixtures/shopify_schema.json")))
          )
          ShopifyCli::Project.expects(:current).returns(
            TestHelpers::FakeProject.new(
              directory: @context.root,
              config: {
                'app_type' => 'node',
              }
            )
          ).at_least_once
          @context.expects(:system).with('npm run-script generate-webhook PRODUCT_CREATE')
          @command.call(['webhook', 'PRODUCT_CREATE'], nil)
        end

        def test_with_selection
          ShopifyCli::Tasks::Schema.expects(:call).returns(
            JSON.parse(File.read(File.join(ShopifyCli::ROOT, "test/fixtures/shopify_schema.json"))),
          )
          ShopifyCli::Project.expects(:current).returns(
            TestHelpers::FakeProject.new(
              directory: @context.root,
              config: {
                'app_type' => 'node',
              }
            )
          ).at_least_once
          CLI::UI::Prompt.expects(:ask).returns('PRODUCT_CREATE')
          @context.expects(:system).with('npm run-script generate-webhook PRODUCT_CREATE')
          @command.call(['webhook'], nil)
        end
      end
    end
  end
end
