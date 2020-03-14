require 'test_helper'

module Rails
  module Commands
    class OpenTest < MiniTest::Test
      def setup
        super
        project_context('app_types', 'rails')
        ShopifyCli::ProjectType.load_type(:rails)
        @context.stubs(:system)
      end

      def test_run
        ShopifyCli::Tasks::Tunnel.stubs(:call).returns('https://example.com')
        Rails::Commands::Open.any_instance.expects(:open_url!).with(@context, 'https://example.com/login?shop=my-test-shop.myshopify.com')
        run_cmd('open')
      end
    end
  end
end
