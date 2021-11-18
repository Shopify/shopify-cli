require "test_helper"
require "semantic/semantic"
require "project_types/node/test_helper"

module ShopifyCLI
  module Services
    module App
      module Create
        class NodeServiceTest < MiniTest::Test
          include TestHelpers::Partners
          include TestHelpers::FakeUI
          include TestHelpers::Shopifolk

          ENV_FILE = <<~CONTENT
            SHOPIFY_API_KEY=newapikey
            SHOPIFY_API_SECRET=secret
            SHOP=testshop.myshopify.com
            SCOPES=write_products,write_customers,write_draft_orders
          CONTENT

          SHOPIFYCLI_FILE = <<~APPTYPE
            ---
            project_type: node
            organization_id: 42
          APPTYPE

          def setup
            super
            ShopifyCLI::Tasks::EnsureAuthenticated.stubs(:call)
          end

          def test_check_node_installed
            @context.expects(:which).with("node").returns(nil)
            assert_raises ShopifyCLI::Abort, "core.app.create.node.error.node_required" do
              call_service
            end
          end

          def test_check_get_node_version
            @context.expects(:which).with("node").returns("/usr/bin/node")
            @context.expects(:capture2e).with("node", "-v").returns([nil, mock(success?: false)])
            assert_raises ShopifyCLI::Abort, "core.app.create.node.error.node_version_failure" do
              call_service
            end
          end

          def test_check_npm_installed
            @context.expects(:which).with("node").returns("/usr/bin/node")
            @context.expects(:capture2e).with("node", "-v").returns(["8.0.0", mock(success?: true)])
            @context.expects(:which).with("npm").returns(nil)
            assert_raises ShopifyCLI::Abort, "core.app.create.node.error.npm_required" do
              call_service
            end
          end

          def test_check_get_npm_version
            @context.expects(:which).with("node").returns("/usr/bin/node")
            @context.expects(:capture2e).with("node", "-v").returns(["8.0.0", mock(success?: true)])
            @context.expects(:which).with("npm").returns("/usr/bin/npm")
            @context.expects(:capture2e).with("npm", "-v").returns([nil, mock(success?: false)])
            assert_raises ShopifyCLI::Abort, "core.app.create.node.error.npm_version_failure" do
              call_service
            end
          end

          def test_check_default_npm_registry_is_production
            create_test_app_directory_structure

            expect_node_npm_check_commands
            @context.expects(:capture2).with("npm config get @shopify:registry").returns(
              ["https://registry.yarnpkg.com", nil]
            )
            ShopifyCLI::Git.expects(:clone).with("https://github.com/Shopify/shopify-app-node.git", "test-app")
            ShopifyCLI::JsDeps.expects(:install)
            ShopifyCLI::Tasks::CreateApiClient.stubs(:call).returns({
              "apiKey" => "ljdlkajfaljf",
              "apiSecretKeys" => [{ "secret": "kldjakljjkj" }],
              "id" => "12345678",
            })
            ShopifyCLI::Resources::EnvFile.stubs(:new).returns(stub(write: true))

            call_service

            refute File.exist?("test-app/.npmrc")
            FileUtils.rm_r("test-app")
          end

          def test_check_default_npm_registry_is_not_production
            create_test_app_directory_structure

            expect_node_npm_check_commands
            @context.expects(:capture2).with("npm config get @shopify:registry").returns(
              ["https://badregistry.com", nil]
            )
            @context.expects(:system).with(
              "npm",
              "--userconfig",
              "./.npmrc",
              "config",
              "set",
              "@shopify:registry",
              "https://registry.yarnpkg.com",
              chdir: @context.root + "/test-app"
            )

            ShopifyCLI::Git.expects(:clone).with("https://github.com/Shopify/shopify-app-node.git", "test-app")
            ShopifyCLI::JsDeps.expects(:install)
            ShopifyCLI::Tasks::CreateApiClient.stubs(:call).returns({
              "apiKey" => "ljdlkajfaljf",
              "apiSecretKeys" => [{ "secret": "kldjakljjkj" }],
              "id" => "12345678",
            })
            ShopifyCLI::Resources::EnvFile.stubs(:new).returns(stub(write: true))

            call_service

            FileUtils.rm_r("test-app")
          end

          def test_can_create_new_app
            create_test_app_directory_structure

            @context.stubs(:uname).returns("Mac")
            expect_node_npm_check_commands
            @context.expects(:capture2).with("npm config get @shopify:registry").returns(
              ["https://registry.yarnpkg.com", nil]
            )
            ShopifyCLI::Git.expects(:clone).with("https://github.com/Shopify/shopify-app-node.git", "test-app")
            ShopifyCLI::JsDeps.expects(:install)

            stub_partner_req(
              "create_app",
              variables: {
                org: 42,
                title: "test-app",
                type: "public",
                app_url: ShopifyCLI::Tasks::CreateApiClient::DEFAULT_APP_URL,
                redir: ["http://127.0.0.1:3456"],
              },
              resp: {
                'data': {
                  'appCreate': {
                    'app': {
                      'apiKey': "newapikey",
                      'apiSecretKeys': [{ 'secret': "secret" }],
                    },
                  },
                },
              }
            )

            call_service

            assert_equal SHOPIFYCLI_FILE, File.read("test-app/.shopify-cli.yml")
            assert_equal ENV_FILE, File.read("test-app/.env")
            refute File.exist?("test-app/.npmrc")
            refute File.exist?("test-app/.git")
            refute File.exist?("test-app/.github")
            refute File.exist?("test-app/server/handlers/client.cli.js")
            assert File.exist?("test-app/server/handlers/client.js")

            FileUtils.rm_r("test-app")
          end

          def test_can_create_new_app_registry_not_found
            create_test_app_directory_structure

            @context.stubs(:uname).returns("Mac")
            expect_node_npm_check_commands
            @context.expects(:capture2).with("npm config get @shopify:registry").returns(
              ["https://badregistry.com", nil]
            )
            ShopifyCLI::Git.expects(:clone).with("https://github.com/Shopify/shopify-app-node.git", "test-app")
            @context.expects(:system).with(
              "npm",
              "--userconfig",
              "./.npmrc",
              "config",
              "set",
              "@shopify:registry",
              "https://registry.yarnpkg.com",
              chdir: @context.root + "/test-app"
            )
            ShopifyCLI::JsDeps.expects(:install)

            stub_partner_req(
              "create_app",
              variables: {
                org: 42,
                title: "test-app",
                type: "public",
                app_url: ShopifyCLI::Tasks::CreateApiClient::DEFAULT_APP_URL,
                redir: ["http://127.0.0.1:3456"],
              },
              resp: {
                'data': {
                  'appCreate': {
                    'app': {
                      'apiKey': "newapikey",
                      'apiSecretKeys': [{ 'secret': "secret" }],
                    },
                  },
                },
              }
            )

            call_service

            assert_equal SHOPIFYCLI_FILE, File.read("test-app/.shopify-cli.yml")
            assert_equal ENV_FILE, File.read("test-app/.env")
            refute File.exist?("test-app/.git")
            refute File.exist?("test-app/.github")
            refute File.exist?("test-app/server/handlers/client.cli.js")
            assert File.exist?("test-app/server/handlers/client.js")

            FileUtils.rm_r("test-app")
          end

          def test_can_create_new_marketplace_app
            create_test_app_directory_structure

            @context.stubs(:uname).returns("Mac")
            expect_node_npm_check_commands
            @context.expects(:capture2).with("npm config get @shopify:registry").returns(
              ["https://registry.yarnpkg.com", nil]
            )
            ShopifyCLI::Git.expects(:clone).with("https://github.com/Shopify/shopify-app-node.git", "test-app")
            @context.expects(:capture2e).with(
              "git",
              "-C",
              File.join(@context.root, "test-app"),
              "checkout",
              "922ec7f8a62d7601e2caa27d34e5b803d257cef4"
            )
            ShopifyCLI::JsDeps.expects(:install)

            stub_partner_req(
              "create_app",
              variables: {
                org: 42,
                title: "test-app",
                type: "public",
                app_url: ShopifyCLI::Tasks::CreateApiClient::DEFAULT_APP_URL,
                redir: ["http://127.0.0.1:3456"],
              },
              resp: {
                'data': {
                  'appCreate': {
                    'app': {
                      'apiKey': "newapikey",
                      'apiSecretKeys': [{ 'secret': "secret" }],
                    },
                  },
                },
              }
            )

            NodeService.call(
              context: @context,
              name: "test-app",
              type: "public",
              organization_id: "42",
              store_domain: "testshop.myshopify.com",
              verbose: false,
              marketplace: true
            )

            assert_equal SHOPIFYCLI_FILE, File.read("test-app/.shopify-cli.yml")
            assert_equal ENV_FILE, File.read("test-app/.env")
            refute File.exist?("test-app/.npmrc")
            refute File.exist?("test-app/.git")
            refute File.exist?("test-app/.github")
            refute File.exist?("test-app/server/handlers/client.cli.js")
            assert File.exist?("test-app/server/handlers/client.js")

            FileUtils.rm_r("test-app")
          end

          private

          def call_service
            NodeService.call(
              context: @context,
              name: "test-app",
              type: "public",
              organization_id: "42",
              store_domain: "testshop.myshopify.com",
              verbose: false,
              marketplace: false
            )
          end

          def expect_node_npm_check_commands
            @context.expects(:which).with("node").returns("/usr/bin/node")
            @context.expects(:capture2e).with("node", "-v").returns(["8.0.0", mock(success?: true)])
            @context.expects(:which).with("npm").returns("/usr/bin/npm")
            @context.expects(:capture2e).with("npm", "-v").returns(["1", mock(success?: true)])
          end

          def create_test_app_directory_structure
            FileUtils.mkdir_p("test-app")
            FileUtils.mkdir_p("test-app/server/handlers")
            FileUtils.touch("test-app/.git")
            FileUtils.touch("test-app/.github")
            FileUtils.touch("test-app/server/handlers/client.js")
            FileUtils.touch("test-app/server/handlers/client.cli.js")
          end
        end
      end
    end
  end
end
