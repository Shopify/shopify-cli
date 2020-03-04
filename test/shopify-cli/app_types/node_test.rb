require 'test_helper'

module ShopifyCli
  module AppTypes
    class NodeBuildTest < MiniTest::Test
      def setup
        @context = TestHelpers::FakeContext.new(root: Dir.mktmpdir, env: {})
        @app = ShopifyCli::AppTypes::Node.new(ctx: @context)
      end
    end
  end
end
