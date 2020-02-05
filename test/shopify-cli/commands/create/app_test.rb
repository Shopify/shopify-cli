require 'test_helper'

module ShopifyCli
  module Commands
    class Create
      class AppTest < MiniTest::Test
        include TestHelpers::Partners
        include TestHelpers::FakeUI

        def setup
          super
          Project.stubs(:current_context).returns(:app)
          @cmd = ShopifyCli::Commands::Create
          @cmd.ctx = @context
        end

        def test_prints_help_with_no_name_argument
          io = capture_io { @cmd.call(['app'], 'create') }
          assert_match(CLI::UI.fmt(ShopifyCli::Commands::Create::App.help), io.join)
        end

        def test_can_create_new_app
          FileUtils.mkdir_p('test-app')
          ShopifyCli::AppTypes::Node.any_instance.expects(:check_dependencies)
          ShopifyCli::AppTypes::Node.any_instance.expects(:build).with('test-app')
          ShopifyCli::Project.expects(:write).with(@context, :app, 'app_type' => :node)
          env_file = MiniTest::Mock.new
          Helpers::EnvFile.expects(:new).with(
            api_key: 'newapikey',
            secret: 'secret',
            shop: 'testshop.myshopify.com',
            scopes: 'write_products,write_customers,write_draft_orders'
          ).returns(env_file)
          env_file.expect(:write, nil, [@context])

          stub_partner_req(
            'create_app',
            variables: {
              org: 42,
              title: 'Test app',
              app_url: 'https://shopify.github.io/shopify-app-cli/getting-started',
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

          @cmd.call(['app', 'test-app', '--type=node', '--organization_id=42',
                     '--shop_domain=testshop.myshopify.com'], 'create')
        end
      end
    end
  end
end
