require 'test_helper'

module ShopifyCli
  module Commands
    class OpenTest < MiniTest::Test
      include TestHelpers::Project

      def setup
        super
        @command = ShopifyCli::Commands::Open.new(@context)
      end

      def test_run
        @context.expects(:system).with('open https://example.com')
        @command.call([], nil)
      end
    end
  end
end
