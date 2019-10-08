require 'test_helper'

module ShopifyCli
  module Commands
    class Create
      class ProjectTest < MiniTest::Test
        include TestHelpers::Context

        def setup
          super
          @command = ShopifyCli::Commands::Create::Project
          @command.ctx = @context
          ShopifyCli::Tasks::Tunnel.any_instance.stubs(:call)
        end

        def test_prints_help_with_no_name_argument
          io = capture_io do
            @command.call([], nil)
          end

          assert_match(CLI::UI.fmt(ShopifyCli::Commands::Create::Project.help), io.join)
        end

        def test_implemented_option
          FileUtils.mkdir_p('test-app')
          CLI::UI::Prompt.expects(:ask).returns(:node)
          ShopifyCli::AppTypes::Node.any_instance.stubs(:check_dependencies)
          ShopifyCli::AppTypes::Node.any_instance.stubs(:build).with('test-app')
          @command.call(['project', 'test-app'], nil)
        end

        def test_with_type_argument
          FileUtils.mkdir_p('test-app')
          CLI::UI::Prompt.expects(:ask).never
          ShopifyCli::AppTypes::Node.any_instance.stubs(:check_dependencies)
          ShopifyCli::AppTypes::Node.any_instance.stubs(:build).with('test-app')
          @command.call(['project', '--type=node', 'test-app'], nil)
        end

        def test_raises_with_invalid_type
          FileUtils.mkdir_p('test-app')
          CLI::UI::Prompt.expects(:ask).never
          ShopifyCli::AppTypes::Node.any_instance.expects(:build).never
          assert_raises ShopifyCli::Abort do
            @command.call(['project', '--type=noder', 'test-app'], nil)
          end
        end
      end
    end
  end
end
