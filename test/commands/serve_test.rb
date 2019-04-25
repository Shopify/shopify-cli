require 'test_helper'

module ShopifyCli
  module Commands
    class ServeTest < MiniTest::Test
      include TestHelpers::AppType

      def setup
        super
        @command = ShopifyCli::Commands::Serve.new(@context)
      end

      def test_run
        @context.expects(:exec).with('a command')
        @command.call([], nil)
      end
    end
  end
end
