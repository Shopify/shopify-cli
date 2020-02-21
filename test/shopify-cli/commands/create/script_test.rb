require 'test_helper'

module ShopifyCli
  module Commands
    class Create
      require 'shopify-cli/commands/create/script'

      class ScriptTest < MiniTest::Test
        def setup
          super
          ENV.stubs(:[]).with('SCRIPTS_PLATFORM').returns('true')
          @cmd = ShopifyCli::Commands::Create::Script.new
          @cmd.ctx = @context
        end

        def test_invalid_ep_error_halts_execution
          @cmd.stubs(:bootstrap).raises(
            ScriptModule::Domain::InvalidExtensionPointError,
            type: 'type'
          )
          ScriptModule::Infrastructure::DependencyManager.expects(:for).never
          capture_io { @cmd.call(['discount', 'name'], 'create') }
        end
      end
    end
  end
end
