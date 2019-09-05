require 'test_helper'

module ShopifyCli
  module Commands
    class OpenTest < MiniTest::Test
      include TestHelpers::Project

      def setup
        super
        @command = ShopifyCli::Commands::Open.new(@context)
      end

      def test_run_mac
        @command.stubs(:mac?).returns(true)
        @context.expects(:system).with('open', 'https://example.com')
        @command.call([], nil)
      end

      def test_run_linux
        @command.stubs(:mac?).returns(false)
        @context.expects(:system).with('python', '-m', 'webserver', 'https://example.com')
        @command.call([], nil)
      end
    end
  end
end
