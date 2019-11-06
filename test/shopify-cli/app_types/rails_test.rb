require 'test_helper'
require 'semantic/semantic'

module ShopifyCli
  module AppTypes
    class RailsBuildTest < MiniTest::Test
      def setup
        project_context('app_types', 'rails')
        @app = ShopifyCli::AppTypes::Rails.new(ctx: @context)
      end

      def test_generate_command
        {
          "SHOP_UPDATE" => "shop/update",
          "DRAFT_ORDER_UPDATE" => "draft_order/update",
          "APP_PURCHASE_ONE_TIME_CREATE" => "app_purchase_one_time/create",
        }.each do |topic, expected|
          actual = Rails.generate_command(topic)
          expected_cmd = "rails g shopify_app:add_webhook -t #{expected} -a https://example.com/webhooks/#{expected}"
          assert_equal expected_cmd, actual
        end
      end

      def test_build_creates_rails_app
        File.stubs(:open).with(File.join(
          @context.root,
          'config',
          'initializers',
          'user_agent.rb'
        ), 'w').returns(nil)
        ShopifyCli::Helpers::Gem.expects(:install).with(@context, 'rails')
        ShopifyCli::Helpers::Gem.expects(:install).with(@context, 'bundler', '~>1.0')
        ShopifyCli::Helpers::Gem.expects(:install).with(@context, 'bundler', '~>2.0')
        @context.expects(:system).with(
          ShopifyCli::Helpers::Gem.binary_path_for(@context, 'rails'), 'new', 'test-app'
        )
        File.expects(:open).with(File.join(@context.root, 'Gemfile'), 'a')
        @context.expects(:system).with(
          ShopifyCli::Helpers::Gem.binary_path_for(@context, 'bundle'),
          'install',
          chdir: @context.root
        )
        @context.expects(:system).with(
          ShopifyCli::Helpers::Gem.binary_path_for(@context, 'rails'),
          'generate',
          'shopify_app',
          chdir: @context.root
        )
        @context.expects(:system).with(
          ShopifyCli::Helpers::Gem.binary_path_for(@context, 'rails'),
          'db:migrate',
          'RAILS_ENV=development',
          chdir: @context.root
        )
        @context.expects(:system).with(
          ShopifyCli::Helpers::Gem.binary_path_for(@context, 'spring'),
          'stop',
          chdir: @context.root
        )
        capture_io do
          @app.build('test-app')
        end
      end

      def test_check_dependencies_exits_if_incorrect_ruby_version
        Helpers::Ruby.expects(:version).returns(Semantic::Version.new('2.3.7'))
        assert_raises ShopifyCli::Abort do
          @app.check_dependencies
        end
      end
    end

    class RailsTest < MiniTest::Test
      include TestHelpers::FakeUI

      def setup
        super
        project_context('app_types', 'rails')
        @app = ShopifyCli::AppTypes::Rails.new(ctx: @context)
        Helpers::EnvFile.any_instance.stubs(:write)
        Helpers::EnvFile.any_instance.stubs(:update)
      end

      def test_server_command
        cmd = ShopifyCli::Commands::Serve
        cmd.ctx = @context
        ShopifyCli::Tasks::Tunnel.stubs(:call)
        ShopifyCli::Tasks::UpdateWhitelistURL.expects(:call)
        @context.expects(:system).with(
          "PORT=8081 bin/rails server"
        )
        run_cmd('serve')
      end

      def test_open_command
        Tasks::Tunnel.expects(:call).at_least_once
        Commands::Open.any_instance.expects(:open_url!).with(
          @context,
          'https://example.com/login?shop=my-test-shop.myshopify.com'
        )
        run_cmd('open')
      end
    end
  end
end
