require 'test_helper'

module ShopifyCli
  module Commands
    class Create
      class ProjectTest < MiniTest::Test
        include TestHelpers::Context
        def setup
          super
          @command = ShopifyCli::Commands::Create.new(@context)
        end

        def test_prints_help_with_no_name_argument
          io = capture_io do
            @command.call([], nil)
          end

          assert_match(CLI::UI.fmt(ShopifyCli::Commands::Create.help), io.join)
        end

        def test_exists_with_not_implemented_choice
          ShopifyCli::Tasks::Tunnel.any_instance.stubs(:call)
          CLI::UI.expects(:ask).twice.returns('apikey', 'apisecret')
          CLI::UI::Prompt.expects(:ask).returns(false)
          io = capture_io do
            @command.call(['project', 'test-app'], nil)
          end

          assert_match('not yet implemented', io.join)
        end

        def test_implemented_option
          ShopifyCli::Tasks::Tunnel.any_instance.stubs(:call)
          FileUtils.mkdir_p('test-app')
          CLI::UI.expects(:ask).twice.returns('apikey', 'apisecret')
          CLI::UI::Prompt.expects(:ask).returns(:node)
          ShopifyCli::AppTypes::Node.any_instance.stubs(:build)
          @command.call(['project', 'test-app'], nil)
          assert_equal 'apikey', @context.app_metadata[:api_key]
          assert_equal 'apisecret', @context.app_metadata[:secret]
        end
      end
    end
  end
end
