require 'test_helper'

module ShopifyCli
  module Commands
    class ServeTest < MiniTest::Test
      include TestHelpers::Project
      include TestHelpers::FakeUI

      def setup
        super
        @command = ShopifyCli::Commands::Serve.new(@context)
      end

      def test_run
        @context.expects(:system).with('a command')
        @command.call([], nil)
      end
    end
  end
end
