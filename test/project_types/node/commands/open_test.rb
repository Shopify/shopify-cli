require 'test_helper'

module Node
  module Commands
    class OpenTest < MiniTest::Test
      def setup
        super
        project_context('app_types', 'node')
        ShopifyCli::ProjectType.load_type(:node)
        @context.stubs(:system)
      end

      def test_run
        @context.expects(:open_url!).with('https://example.com/auth?shop=my-test-shop.myshopify.com')
        run_cmd('open')
      end
    end
  end
end
