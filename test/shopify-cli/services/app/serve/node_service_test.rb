require "test_helper"
require "semantic/semantic"
require "project_types/node/test_helper"

module ShopifyCLI
  module Services
    module App
      module Serve
        class NodeServiceTest < MiniTest::Test
          include TestHelpers::FakeUI

          def setup
            super
            project_context("app_types", "node")
            ShopifyCLI::Tasks::EnsureDevStore.stubs(:call)
            @context.stubs(:system)
          end

          def test_call
            ShopifyCLI::Tunnel.stubs(:start).returns("https://example.com")
            ShopifyCLI::Tasks::UpdateDashboardURLS.expects(:call)
            ShopifyCLI::Resources::EnvFile.any_instance.expects(:update)
            @context.expects(:system).with(
              "npm run dev",
              env: {
                "SHOPIFY_API_KEY" => "mykey",
                "SHOPIFY_API_SECRET" => "mysecretkey",
                "SHOP" => "my-test-shop.myshopify.com",
                "SCOPES" => "read_products",
                "HOST" => "https://example.com",
                "PORT" => "8081",
              }
            )
            run_cmd("app serve")
          end

          def test_call_with_invalid_host_url
            ShopifyCLI::Tunnel.stubs(:start).returns("garbage://example.com")
            ShopifyCLI::Tasks::UpdateDashboardURLS.expects(:call).never
            ShopifyCLI::Resources::EnvFile.any_instance.expects(:update).never
            @context.expects(:system).with(
              "npm run dev",
              env: {
                "SHOPIFY_API_KEY" => "mykey",
                "SHOPIFY_API_SECRET" => "mysecretkey",
                "SHOP" => "my-test-shop.myshopify.com",
                "SCOPES" => "read_products",
                "HOST" => "garbage://example.com",
                "PORT" => "8081",
              }
            ).never

            assert_raises ShopifyCLI::Abort do
              run_cmd("app serve")
            end
          end

          def test_open_while_run
            ShopifyCLI::Tunnel.stubs(:start).returns("https://example.com")
            ShopifyCLI::Tasks::UpdateDashboardURLS.expects(:call)
            ShopifyCLI::Resources::EnvFile.any_instance.expects(:update).with(
              @context, :host, "https://example.com"
            )
            @context.expects(:puts).with(
              "\n" +
              @context.message("core.app.serve.open_info", "https://example.com/auth?shop=my-test-shop.myshopify.com") +
              "\n"
            )
            run_cmd("app serve")
          end

          def test_call_when_host_passed
            ShopifyCLI::Tunnel.expects(:start).never
            ShopifyCLI::Tasks::UpdateDashboardURLS.expects(:call)
            ShopifyCLI::Resources::EnvFile.any_instance.expects(:update).with(
              @context, :host, "https://example-foo.com"
            )
            run_cmd('app serve --host="https://example-foo.com"')
          end

          def test_call_when_invalid_host_passed
            invalid_host = "garbage://example.com"
            ShopifyCLI::Tasks::UpdateDashboardURLS.expects(:call).never
            ShopifyCLI::Resources::EnvFile.any_instance.expects(:update).never
            @context.expects(:system).with(
              "npm run dev",
              env: {
                "SHOPIFY_API_KEY" => "mykey",
                "SHOPIFY_API_SECRET" => "mysecretkey",
                "SHOP" => "my-test-shop.myshopify.com",
                "SCOPES" => "read_products",
                "HOST" => "garbage://example.com",
                "PORT" => "8081",
              }
            ).never

            assert_raises ShopifyCLI::Abort do
              run_cmd("app serve --host=#{invalid_host}")
            end
          end

          def test_call_when_port_passed
            ShopifyCLI::Tunnel.stubs(:start).returns("https://example.com")
            ShopifyCLI::Tunnel.expects(:start).with(@context, port: 5000).returns("https://example.com")
            ShopifyCLI::Tasks::UpdateDashboardURLS.expects(:call)
            ShopifyCLI::Resources::EnvFile.any_instance.expects(:update)
            @context.expects(:system).with(
              "npm run dev",
              env: {
                "SHOPIFY_API_KEY" => "mykey",
                "SHOPIFY_API_SECRET" => "mysecretkey",
                "SHOP" => "my-test-shop.myshopify.com",
                "SCOPES" => "read_products",
                "HOST" => "https://example.com",
                "PORT" => "5000",
              }
            )
            run_cmd("app serve --port=5000")
          end

          def test_call_when_invalid_port_passed
            invalid_port = "NOT_PORT"
            ShopifyCLI::Tunnel.stubs(:start).returns("https://example.com")
            ShopifyCLI::Tasks::UpdateDashboardURLS.expects(:call)
            ShopifyCLI::Resources::EnvFile.any_instance.expects(:update)
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
