require 'test_helper'

module ShopifyCli
  module Commands
    class ServeTest < MiniTest::Test
      include TestHelpers::FakeUI

      def setup
        super
        @command = ShopifyCli::Commands::Serve
        @command.ctx = @context
      end

      def test_run
        Tasks::Tunnel.stubs(:call)
        Tasks::UpdateWhitelistURL.stubs(:call)
        @context.expects(:system).with('a command')
        run_cmd('serve')
      end

      def test_open_while_run
        @command.stubs(:on_siginfo).yields
        puts ShopifyCli::Tasks::Tunnel.stubs(:call).returns('https://example.com')
        @command.stubs(:update_env).with('https://example.com')
        ShopifyCli::Tasks::UpdateWhitelistURL.expects(:call)
        @command.stubs(:mac?).returns(true)
        Open.any_instance.expects(:open_url!).with(
          @context,
          'https://example.com',
        )
        @context.expects(:system).with('a command')
        run_cmd('serve')
      end
    end
  end
end
