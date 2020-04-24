require 'test_helper'

module Rails
  module Commands
    class OpenTest < MiniTest::Test
      def setup
        super
        ShopifyCli::Project.stubs(:current_project_type).returns(:rails)
      end

      def test_run
        @context.expects(:open_url!).with('https://example.com/login?shop=my-test-shop.myshopify.com')
        run_cmd('open')
      end
    end
  end
end
