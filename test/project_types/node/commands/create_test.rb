require 'test_helper'
require 'semantic/semantic'

module Node
  module Commands
    class CreateTest < MiniTest::Test
      include TestHelpers::Partners
      include TestHelpers::FakeUI

      ENV_FILE = <<~CONTENT
        SHOPIFY_API_KEY=newapikey
        SHOPIFY_API_SECRET=secret
        SHOP=testshop.myshopify.com
        SCOPES=write_products,write_customers,write_draft_orders
      CONTENT

      SHOPIFYCLI_FILE = <<~APPTYPE
        ---
        app_type: node
      APPTYPE

      def setup
        super
        ShopifyCli::ProjectType.load_type(:node)
      end

      def test_prints_help_with_no_name_argument
        io = capture_io { run_cmd('create node --help') }
        assert_match(CLI::UI.fmt(Node::Commands::Create.help), io.join)
      end

      def test_check_node_installed
        @context.expects(:capture2e).with('node', '-v').returns([nil, mock(success?: false)])
        assert_raises ShopifyCli::Abort, Create::NODE_REQUIRED_NOTICE do
          perform_command
        end
      end

      def test_check_npm_installed
        Create.any_instance.stubs(:check_node)
        @context.expects(:capture2e).with('npm', '-v').returns([nil, mock(success?: false)])
        assert_raises ShopifyCli::Abort, Create::NPM_REQUIRED_NOTICE do
          perform_command
        end
      end

      def test_check_npm_registry
        @context.expects(:capture2e).with('npm', '-v').returns(['1', mock(success?: true)])
        @context.expects(:capture2e).with('node', '-v').returns(['8.0.0', mock(success?: true)])
        @context.expects(:capture2).with('npm config get @shopify:registry').returns(
          ['https://badregistry.com', nil]
        )
        assert_raises ShopifyCli::Abort, Create::NPM_REGISTRY_NOTICE do
          perform_command
        end
      end

      def test_can_create_new_app
        FileUtils.mkdir_p('test-app')
        FileUtils.mkdir_p('test-app/server/handlers')
        FileUtils.touch('test-app/.git')
        FileUtils.touch('test-app/.github')
        FileUtils.touch('test-app/server/handlers/client.js')
        FileUtils.touch('test-app/server/handlers/client.cli.js')

        @context.stubs(:uname).with(flag: 'v').returns('Mac')
        @context.expects(:capture2e).with('npm', '-v').returns(['1', mock(success?: true)])
        @context.expects(:capture2e).with('node', '-v').returns(['8.0.0', mock(success?: true)])
        @context.expects(:capture2).with('npm config get @shopify:registry').returns(
          ['https://registry.yarnpkg.com', nil]
        )
        ShopifyCli::Git.expects(:clone).with('https://github.com/Shopify/shopify-app-node.git', 'test-app')
        JsDeps.expects(:install)

        stub_partner_req(
          'create_app',
          variables: {
            org: 42,
            title: 'test-app',
            type: 'public',
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

        perform_command

        assert_equal SHOPIFYCLI_FILE, File.read("test-app/.shopify-cli.yml")
        assert_equal ENV_FILE, File.read("test-app/.env")
        refute File.exist?("test-app/.git")
        refute File.exist?("test-app/.github")
        refute File.exist?('test-app/server/handlers/client.cli.js')
        assert File.exist?('test-app/server/handlers/client.js')

        FileUtils.rm_r('test-app')
      end

      private

      def expect_command(command, chdir: @context.root)
        @context.expects(:system).with(*command, chdir: chdir)
      end

      def perform_command
        run_cmd("create node \
          --title=test-app \
          --type=public \
          --organization_id=42 \
          --shop_domain=testshop.myshopify.com")
      end
    end
  end
end

