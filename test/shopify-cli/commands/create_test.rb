require 'test_helper'

module ShopifyCli
  module Commands
    class CreateTest < MiniTest::Test
      include TestHelpers::Constants

      def setup
        super
        load_cmd
      end

      def test_without_arguments_calls_help
        @context.expects(:puts).with(ShopifyCli::Commands::Create.help)
        @cmd.call([], @cmd_name)
      end

      def test_with_create_app
        Create::App.any_instance.expects(:call)
          .with(['new-app'], 'app')
        @cmd.call(['app', 'new-app'], @cmd_name)
      end

      def test_with_create_script_with_env_var_set
        ENV.stubs(:[]).with('SCRIPTS_PLATFORM').returns('true')
        load_cmd

        Create::Script.any_instance.expects(:call)
          .with(['discount', 'new-script'], 'script')
        @cmd.call(['script', 'discount', 'new-script'], @cmd_name)
      end

      def test_create_script_is_hidden_unless_env_is_set
        ENV.stubs(:[]).with('SCRIPTS_PLATFORM').returns(nil)
        load_cmd

        Create::Script.any_instance.expects(:call).never
        @cmd.call(['script', 'discount', 'new-script'], @cmd_name)
        assert_nil(@cmd.subcommand_registry.lookup_command('script').first)
      end

      def test_with_create_project_returns_warning
        io = capture_io do
          @cmd.call(['project', 'new-app'], @cmd_name)
        end
        assert_match('shopify create app', io.join)
      end

      private

      def load_cmd
        reload_class
        @cmd = ShopifyCli::Commands::Create
        @cmd.ctx = @context
        @cmd_name = 'create'
      end

      def reload_class
        ignore_constant_redefined_warnings do
          ShopifyCli::Commands.send(:remove_const, :Create)
          load('shopify-cli/commands/create.rb')
          load('shopify-cli/commands/create/app.rb')
          load('shopify-cli/commands/create/script.rb')
        end
      end
    end
  end
end
