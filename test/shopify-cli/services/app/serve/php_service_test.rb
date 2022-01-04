# typed: ignore
require "test_helper"
require "semantic/semantic"
require "project_types/php/test_helper"

module ShopifyCLI
  module Services
    module App
      module Serve
        class PHPServiceTest < MiniTest::Test
          include TestHelpers::FakeUI

          def setup
            super
            project_context("app_types", "php")
            ShopifyCLI::Tasks::EnsureDevStore.stubs(:call)
            @context.stubs(:system)
          end

          def test_server_command
            ShopifyCLI::Tunnel.stubs(:start).returns("https://example.com")
            ShopifyCLI::Tasks::UpdateDashboardURLS.expects(:call)
            ShopifyCLI::Resources::EnvFile.any_instance.expects(:update)
            ShopifyCLI::ProcessSupervision.expects(:running?).with(:npm_watch).returns(false)
            ShopifyCLI::ProcessSupervision.expects(:stop).never
            ShopifyCLI::ProcessSupervision.expects(:start).with(:npm_watch, "npm run watch", force_spawn: true)

            @context.expects(:system).with(
              "php",
              "artisan",
              "serve",
              "--port",
              "8081",
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
              @context.message("core.app.serve.open_info",
                "https://example.com/login?shop=my-test-shop.myshopify.com") +
              "\n"
            )

            run_cmd("app serve")
          end

          def test_restarts_npm_watch_if_running
            ShopifyCLI::Tunnel.stubs(:start).returns("https://example.com")
            ShopifyCLI::Tasks::UpdateDashboardURLS.expects(:call)
            ShopifyCLI::Resources::EnvFile.any_instance.expects(:update)
            ShopifyCLI::ProcessSupervision.expects(:running?).with(:npm_watch).returns(true)
            ShopifyCLI::ProcessSupervision.expects(:stop).with(:npm_watch)
            ShopifyCLI::ProcessSupervision.expects(:start).with(:npm_watch, "npm run watch", force_spawn: true)

            @context.expects(:system).with(
              "php",
              "artisan",
              "serve",
              "--port",
              "8081",
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
              @context.message("core.app.serve.open_info",
                "https://example.com/login?shop=my-test-shop.myshopify.com") +
              "\n"
            )

            run_cmd("app serve")
          end

          def test_update_env_with_host
            ShopifyCLI::Tunnel.expects(:start).never
            ShopifyCLI::Tasks::UpdateDashboardURLS.expects(:call)
            ShopifyCLI::Resources::EnvFile.any_instance.expects(:update).with(
              @context, :host, "https://example-foo.com"
            )
            run_cmd('app serve --host="https://example-foo.com"')
          end

          def test_server_command_when_invalid_host_passed
            invalid_host = "garbage://example.com"
            ShopifyCLI::Tasks::UpdateDashboardURLS.expects(:call).never
            ShopifyCLI::Resources::EnvFile.any_instance.expects(:update).never
            ShopifyCLI::ProcessSupervision.expects(:stop).never
            ShopifyCLI::ProcessSupervision.expects(:start).never

            @context.expects(:system).with(
              "app",
              "php",
              "artisan",
              "serve",
              "--port",
              "8081",
              env: {
                "SHOPIFY_API_KEY" => "mykey",
                "SHOPIFY_API_SECRET" => "mysecretkey",
                "SHOP" => "my-test-shop.myshopify.com",
                "SCOPES" => "read_products",
                "HOST" => "https://example.com",
                "DB_DATABASE" => "storage/db.sqlite",
              }
            ).never

            assert_raises ShopifyCLI::Abort do
              run_cmd("app serve --host=#{invalid_host}")
            end
          end

          def test_server_command_when_port_passed
            ShopifyCLI::Tasks::UpdateDashboardURLS.expects(:call)
            ShopifyCLI::Resources::EnvFile.any_instance.expects(:update)
            ShopifyCLI::ProcessSupervision.expects(:running?).with(:npm_watch).returns(false)
            ShopifyCLI::ProcessSupervision.expects(:stop).never
            ShopifyCLI::ProcessSupervision.expects(:start).with(:npm_watch, "npm run watch", force_spawn: true)
            ShopifyCLI::Tunnel.expects(:start).with(@context, port: 5000).returns("https://example.com")

            @context.expects(:system).with(
              "php",
              "artisan",
              "serve",
              "--port",
              "5000",
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
              @context.message("core.app.serve.open_info",
                "https://example.com/login?shop=my-test-shop.myshopify.com") +
              "\n"
            )

            run_cmd("app serve --port=5000")
          end

          def test_server_command_when_invalid_port_passed
            invalid_port = "NOT_PORT"
            ShopifyCLI::Tunnel.stubs(:start).returns("https://example.com")
            ShopifyCLI::Tasks::UpdateDashboardURLS.expects(:call)
            ShopifyCLI::Resources::EnvFile.any_instance.expects(:update)
            ShopifyCLI::ProcessSupervision.expects(:running?).with(:npm_watch).returns(false)
            ShopifyCLI::ProcessSupervision.expects(:stop).never
            ShopifyCLI::ProcessSupervision.expects(:start).with(:npm_watch, "npm run watch", force_spawn: true)
            @context.expects(:abort).with(
              @context.message("core.app.serve.error.invalid_port", invalid_port)
            )

            run_cmd("app serve --port=#{invalid_port}")
          end
        end
      end
    end
  end
end
