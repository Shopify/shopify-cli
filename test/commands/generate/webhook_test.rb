require 'test_helper'

module ShopifyCli
  module Commands
    class Generate
      class WebhookTest < MiniTest::Test
        include TestHelpers::Context

        def setup
          super
          @command = ShopifyCli::Commands::Generate.new(@context)
        end

        def test_with_param
          ShopifyCli::Project.write(@context, :node)
          @context.expects(:exec).with('npm run-script generate-webhook PRODUCT_CREATE')
          @command.call(['webhook', 'PRODUCT_CREATE'], nil)
        end

        def test_with_selection
          ShopifyCli::Project.write(@context, :node)
          CLI::UI::Prompt.expects(:ask).returns('PRODUCT_CREATE')
          @context.expects(:exec).with('npm run-script generate-webhook PRODUCT_CREATE')
          @command.call(['webhook'], nil)
        end
      end
    end
  end
end
