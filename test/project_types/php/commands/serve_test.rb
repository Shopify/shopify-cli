# frozen_string_literal: true
require "project_types/php/test_helper"

module PHP
  module Commands
    class ServeTest < MiniTest::Test
      include TestHelpers::FakeUI

      def setup
        super
        project_context("app_types", "php")
        ShopifyCli::Tasks::EnsureDevStore.stubs(:call)
        @context.stubs(:system)
      end

      def test_server_command
        ShopifyCli::Tunnel.stubs(:start).returns("https://example.com")
        ShopifyCli::Tasks::UpdateDashboardURLS.expects(:call)
        ShopifyCli::Resources::EnvFile.any_instance.expects(:update)
        ShopifyCli::ProcessSupervision.expects(:running?).with(:npm_watch).returns(false)
        ShopifyCli::ProcessSupervision.expects(:stop).never
        ShopifyCli::ProcessSupervision.expects(:start).with(:npm_watch, "npm run watch", force_spawn: true)

        @context.expects(:system).with(
          "php",
          "artisan",
          "serve",
          "--port",
          "3000",
          env: {
            "SHOPIFY_API_KEY" => "mykey",
            "SHOPIFY_API_SECRET" => "mysecretkey",
            "SHOP" => "my-test-shop.myshopify.com",
            "SCOPES" => "read_products",
            "HOST" => "https://example.com",
            "DB_DATABASE" => "storage/db.sqlite",
          }
        )

        @context.expects(:puts).with(
          "\n" +
          @context.message("php.serve.open_info", "https://example.com/login?shop=my-test-shop.myshopify.com") +
          "\n"
        )

        run_cmd("serve")
      end

      def test_restarts_npm_watch_if_running
        ShopifyCli::Tunnel.stubs(:start).returns("https://example.com")
        ShopifyCli::Tasks::UpdateDashboardURLS.expects(:call)
        ShopifyCli::Resources::EnvFile.any_instance.expects(:update)
        ShopifyCli::ProcessSupervision.expects(:running?).with(:npm_watch).returns(true)
        ShopifyCli::ProcessSupervision.expects(:stop).with(:npm_watch)
        ShopifyCli::ProcessSupervision.expects(:start).with(:npm_watch, "npm run watch", force_spawn: true)

        @context.expects(:system).with(
          "php",
          "artisan",
          "serve",
          "--port",
          "3000",
          env: {
            "SHOPIFY_API_KEY" => "mykey",
            "SHOPIFY_API_SECRET" => "mysecretkey",
            "SHOP" => "my-test-shop.myshopify.com",
            "SCOPES" => "read_products",
            "HOST" => "https://example.com",
            "DB_DATABASE" => "storage/db.sqlite",
          }
        )

        @context.expects(:puts).with(
          "\n" +
          @context.message("php.serve.open_info", "https://example.com/login?shop=my-test-shop.myshopify.com") +
          "\n"
        )

        run_cmd("serve")
      end

      def test_server_command_with_invalid_host_url
        ShopifyCli::Tunnel.stubs(:start).returns("garbage://example.com")
        ShopifyCli::Tasks::UpdateDashboardURLS.expects(:call).never
        ShopifyCli::Resources::EnvFile.any_instance.expects(:update).never
        ShopifyCli::ProcessSupervision.expects(:stop).never
        ShopifyCli::ProcessSupervision.expects(:start).never

        @context.expects(:system).with(
          "php",
          "artisan",
          "serve",
          "--port",
          "3000",
          env: {
            "SHOPIFY_API_KEY" => "mykey",
            "SHOPIFY_API_SECRET" => "mysecretkey",
            "SHOP" => "my-test-shop.myshopify.com",
            "SCOPES" => "read_products",
            "HOST" => "https://example.com",
            "DB_DATABASE" => "storage/db.sqlite",
          }
        ).never

        assert_raises ShopifyCli::Abort do
          run_cmd("serve")
        end
      end

      def test_update_env_with_host
        ShopifyCli::Tunnel.expects(:start).never
        ShopifyCli::Tasks::UpdateDashboardURLS.expects(:call)
        ShopifyCli::Resources::EnvFile.any_instance.expects(:update).with(
          @context, :host, "https://example-foo.com"
        )
        run_cmd('serve --host="https://example-foo.com"')
      end
    end
  end
end
