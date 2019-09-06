require 'test_helper'

module ShopifyCli
  module Commands
    class Create
      class ProjectTest < MiniTest::Test
        include TestHelpers::Context

        def setup
          super
          @command = ShopifyCli::Commands::Create::Project.new(@context)
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
          ShopifyCli::AppTypes::Node.any_instance.stubs(:build)
          @command.call(['project', 'test-app'], nil)
        end
      end
    end
  end
end
