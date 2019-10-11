require 'test_helper'

module ShopifyCli
  module Commands
    class Create
      class ProjectTest < MiniTest::Test
        include TestHelpers::Context
        include TestHelpers::Partners

        def setup
          super
          @command = ShopifyCli::Commands::Create::Project
          @command.ctx = @context
        end

        def test_prints_help_with_no_name_argument
          io = capture_io { @command.call([], nil) }
          assert_match(CLI::UI.fmt(ShopifyCli::Commands::Create::Project.help), io.join)
        end

        def test_can_create_new_app
          FileUtils.mkdir_p('test-app')
          ShopifyCli::AppTypes::Node.any_instance.expects(:check_dependencies)
          ShopifyCli::AppTypes::Node.any_instance.expects(:build).with('test-app')

          stub_partner_req(
            'create_app',
            variables: {
              org: 42,
              title: 'Test app',
              app_url: 'http://app.com',
              redir: ["http://app-cli-loopback.shopifyapps.com:3456"],
            },
            resp: {
              'data': {
                'appCreate': {
                  'app': {
                    'apiKey': 'newapikey',
                    'apiSecretKeys': [{ 'secret': 'secret' }],
                  },
                },
              },
            }
          )

          perform_command

          app_type = <<~APPTYPE
            ---
            app_type: :node
          APPTYPE
          assert_equal app_type, File.read("test-app/.shopify-cli.yml")

          env_file = <<~CONTENT
            SHOPIFY_API_KEY=newapikey
            SHOPIFY_API_SECRET=secret
            SHOP=testshop.myshopify.com
            SCOPES=write_products,write_customers,write_draft_orders
          CONTENT
          assert_equal env_file, File.read("test-app/.env")
        end

        private

        def perform_command
          @command.call([
            'project',
            'test-app',
            '--type=node',
            '--app_url=http://app.com',
            '--organization_id=42',
            '--shop_domain=testshop.myshopify.com',
          ], nil)
        end
      end
    end
  end
end
