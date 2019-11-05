require 'test_helper'

module ShopifyCli
  module Commands
    class ServeTest < MiniTest::Test
      include TestHelpers::FakeUI

      def test_run
        Tasks::Tunnel.stubs(:call)
        Tasks::UpdateWhitelistURL.stubs(:call)
        Helpers::EnvFile.any_instance.expects(:update)
        @context.expects(:system).with('a command')
        run_cmd('serve')
      end

      def test_open_while_run
        Serve.any_instance.stubs(:on_siginfo).yields
        ShopifyCli::Tasks::Tunnel.stubs(:call).returns('https://example.com')
        ShopifyCli::Tasks::UpdateWhitelistURL.expects(:call)
        Helpers::EnvFile.any_instance.expects(:update).with(
          @context, :host, 'https://example.com'
        )
        Serve.any_instance.stubs(:mac?).returns(true)
        Open.any_instance.expects(:open_url!).with(
          @context,
          'https://example.com',
        )
        run_cmd('serve')
      end

      def test_update_env_with_host
        ShopifyCli::Tasks::Tunnel.expects(:call).never
        ShopifyCli::Tasks::UpdateWhitelistURL.expects(:call)
        Helpers::EnvFile.any_instance.expects(:update).with(
          @context, :host, 'https://example-foo.com'
        )
        run_cmd('serve --host="https://example-foo.com"')
      end
    end
  end
end
