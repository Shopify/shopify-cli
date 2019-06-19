require 'test_helper'

module ShopifyCli
  module Commands
    class Generate
      class WebhookTest < MiniTest::Test
        include TestHelpers::Context
        include TestHelpers::AppType
        def setup
          super
          @command = ShopifyCli::Commands::Generate.new(@context)
        end

        def test_with_param
          ShopifyCli::Project.expects(:current).returns(
            TestHelpers::FakeProject.new(
              directory: @context.root,
              config: {
                'app_type' => 'node',
              }
            )
          ).at_least_once
          ShopifyCli::Tasks::Schema.expects(:call).returns(
            JSON.parse(File.read(File.join(ShopifyCli::ROOT, "test/fixtures/shopify_schema.json")))
          )
          @context.expects(:system).with('npm run-script generate-webhook --silent PRODUCT_CREATE')
            .returns(mock(success?: true))
          @command.call(['webhook', 'PRODUCT_CREATE'], nil)
        end

        def test_with_selection
          ShopifyCli::Project.expects(:current).returns(
            TestHelpers::FakeProject.new(
              directory: @context.root,
              config: {
                'app_type' => 'node',
              }
            )
          ).at_least_once
          ShopifyCli::Tasks::Schema.expects(:call).returns(
            JSON.parse(File.read(File.join(ShopifyCli::ROOT, "test/fixtures/shopify_schema.json"))),
          )
          CLI::UI::Prompt.expects(:ask).returns('PRODUCT_CREATE')
          @context.expects(:system).with('npm run-script generate-webhook --silent PRODUCT_CREATE')
            .returns(mock(success?: true))
          @command.call(['webhook'], nil)
        end
      end
    end
  end
end
