require 'test_helper'

module Node
  module Commands
    class OpenTest < MiniTest::Test
      def setup
        super
        ShopifyCli::Project.stubs(:current_project_type).returns(:node)
      end

      def test_run
        @context.expects(:open_url!).with('https://example.com/auth?shop=my-test-shop.myshopify.com')
        run_cmd('open')
      end
    end
  end
end
