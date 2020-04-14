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
        @context.expects(:open_url!).with('https://example.com/login?shop=my-test-shop.myshopify.com')
        run_cmd('open')
      end
    end
  end
end
