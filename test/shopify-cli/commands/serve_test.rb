require 'test_helper'

module ShopifyCli
  module Commands
    class ServeTest < MiniTest::Test
      include TestHelpers::FakeUI

      def test_run
        Tasks::Tunnel.stubs(:call)
        Tasks::UpdateWhitelistURL.stubs(:call)
        @context.expects(:system).with('a command')
        run_cmd('serve')
      end

      def test_open_while_run
        Serve.any_instance.stubs(:on_siginfo).yields
        Tasks::Tunnel.stubs(:call)
        Tasks::UpdateWhitelistURL.expects(:call)
        Serve.any_instance.stubs(:mac?).returns(true)
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
