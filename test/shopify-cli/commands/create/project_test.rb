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
          CLI::UI.expects(:ask).times(3)
            .returns('apikey', 'apisecret', 'test-shop.myshopify.com')
          CLI::UI::Prompt.expects(:ask).returns(:node)
          ShopifyCli::AppTypes::Node.any_instance.stubs(:check_dependencies)
          ShopifyCli::AppTypes::Node.any_instance.stubs(:build)
          @command.call(['test-app'], nil)
          assert_equal 'apikey', @context.app_metadata[:api_key]
          assert_equal 'apisecret', @context.app_metadata[:secret]
          assert_equal 'test-shop.myshopify.com', @context.app_metadata[:shop]
        end

        def test_ask_for_credentials_strips_out_https_from_shop
          CLI::UI.expects(:ask).times(3)
            .returns('apikey', 'apisecret', 'https://test-shop.myshopify.com')
          @command.ask_for_credentials
          assert_equal 'test-shop.myshopify.com', @context.app_metadata[:shop]
        end
      end
    end
  end
end
