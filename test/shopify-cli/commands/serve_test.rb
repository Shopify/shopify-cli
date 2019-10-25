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
        ShopifyCli::Tasks::Tunnel.stubs(:call)
        ShopifyCli::Tasks::UpdateWhitelistURL.stubs(:call)
        @context.expects(:system).with('a command')
        @command.call([], nil)
      end

      def test_open_while_run
        @command.stubs(:on_siginfo).yields
        ShopifyCli::Tasks::Tunnel.stubs(:call)
        ShopifyCli::Tasks::UpdateWhitelistURL.expects(:call)
        @command.stubs(:mac?).returns(true)
        Open.any_instance.expects(:open_url!).with(
          @context,
          'https://example.com',
        )
        @command.call([], nil)
      end
    end
  end
end
