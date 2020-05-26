# frozen_string_literal: true
require 'project_types/node/test_helper'
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
        project_type: node
        organization_id: 42
      APPTYPE

      def test_prints_help_with_no_name_argument
        io = capture_io { run_cmd('create node --help') }
        assert_match(CLI::UI.fmt(Node::Commands::Create.help), io.join)
      end

      def test_check_node_installed
        @context.expects(:capture2e).with('which', 'node').returns([nil, mock(success?: false)])
        assert_raises ShopifyCli::Abort, 'node.create.error.node_required' do
          perform_command
        end
      end

      def test_check_get_node_version
        @context.expects(:capture2e).with('which', 'node').returns(['/usr/bin/node', mock(success?: true)])
        @context.expects(:capture2e).with('node', '-v').returns([nil, mock(success?: false)])
        assert_raises ShopifyCli::Abort, 'node.create.error.node_version_failure' do
          perform_command
        end
      end

      def test_check_npm_installed
        @context.expects(:capture2e).with('which', 'node').returns(['/usr/bin/node', mock(success?: true)])
        @context.expects(:capture2e).with('node', '-v').returns(['8.0.0', mock(success?: true)])
        @context.expects(:capture2e).with('which', 'npm').returns([nil, mock(success?: false)])
        assert_raises ShopifyCli::Abort, 'node.create.error.npm_required' do
          perform_command
        end
      end

      def test_check_get_npm_version
        @context.expects(:capture2e).with('which', 'node').returns(['/usr/bin/node', mock(success?: true)])
        @context.expects(:capture2e).with('node', '-v').returns(['8.0.0', mock(success?: true)])
        @context.expects(:capture2e).with('which', 'npm').returns(['/usr/bin/npm', mock(success?: true)])
        @context.expects(:capture2e).with('npm', '-v').returns([nil, mock(success?: false)])
        assert_raises ShopifyCli::Abort, 'node.create.error.npm_version_failure' do
          perform_command
        end
      end

      def test_check_default_npm_registry_is_production
        FileUtils.mkdir_p('test-app')
        FileUtils.mkdir_p('test-app/server/handlers')
        FileUtils.touch('test-app/.git')
        FileUtils.touch('test-app/.github')
        FileUtils.touch('test-app/server/handlers/client.js')
        FileUtils.touch('test-app/server/handlers/client.cli.js')

        expect_node_npm_check_commands
        @context.expects(:capture2).with('npm config get @shopify:registry').returns(
          ['https://registry.yarnpkg.com', nil]
        )
        ShopifyCli::Git.expects(:clone).with('https://github.com/Shopify/shopify-app-node.git', 'test-app')
        ShopifyCli::JsDeps.expects(:install)
        ShopifyCli::Tasks::CreateApiClient.stubs(:call).returns({
          "apiKey" => "ljdlkajfaljf",
          "apiSecretKeys" => [{ "secret": "kldjakljjkj" }],
          "id" => "12345678",
        })
        ShopifyCli::Resources::EnvFile.stubs(:new).returns(stub(write: true))

        perform_command

        refute File.exist?("test-app/.npmrc")
        FileUtils.rm_r('test-app')
      end

      def test_check_default_npm_registry_is_not_production
        FileUtils.mkdir_p('test-app')
        FileUtils.mkdir_p('test-app/server/handlers')
        FileUtils.touch('test-app/.git')
        FileUtils.touch('test-app/.github')
        FileUtils.touch('test-app/server/handlers/client.js')
        FileUtils.touch('test-app/server/handlers/client.cli.js')

        expect_node_npm_check_commands
        @context.expects(:capture2).with('npm config get @shopify:registry').returns(
          ['https://badregistry.com', nil]
        )
        @context.expects(:system).with(
          'npm',
          '--userconfig',
          './.npmrc',
          'config',
          'set',
          '@shopify:registry',
          'https://registry.yarnpkg.com',
          chdir: @context.root + '/test-app'
        )

        ShopifyCli::Git.expects(:clone).with('https://github.com/Shopify/shopify-app-node.git', 'test-app')
        ShopifyCli::JsDeps.expects(:install)
        ShopifyCli::Tasks::CreateApiClient.stubs(:call).returns({
          "apiKey" => "ljdlkajfaljf",
          "apiSecretKeys" => [{ "secret": "kldjakljjkj" }],
          "id" => "12345678",
        })
        ShopifyCli::Resources::EnvFile.stubs(:new).returns(stub(write: true))

        perform_command

        FileUtils.rm_r('test-app')
      end

      def test_can_create_new_app
        FileUtils.mkdir_p('test-app')
        FileUtils.mkdir_p('test-app/server/handlers')
        FileUtils.touch('test-app/.git')
        FileUtils.touch('test-app/.github')
        FileUtils.touch('test-app/server/handlers/client.js')
        FileUtils.touch('test-app/server/handlers/client.cli.js')

        @context.stubs(:uname).returns('Mac')
        expect_node_npm_check_commands
        @context.expects(:capture2).with('npm config get @shopify:registry').returns(
          ['https://registry.yarnpkg.com', nil]
        )
        ShopifyCli::Git.expects(:clone).with('https://github.com/Shopify/shopify-app-node.git', 'test-app')
        ShopifyCli::JsDeps.expects(:install)

        stub_partner_req(
          'create_app',
          variables: {
            org: 42,
            title: 'test-app',
            type: 'public',
            app_url: 'https://shopify.github.io/shopify-app-cli/getting-started',
            redir: ["http://127.0.0.1:3456"],
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
        refute File.exist?("test-app/.npmrc")
        refute File.exist?("test-app/.git")
        refute File.exist?("test-app/.github")
        refute File.exist?('test-app/server/handlers/client.cli.js')
        assert File.exist?('test-app/server/handlers/client.js')

        FileUtils.rm_r('test-app')
      end

      def test_can_create_new_app_registry_not_found
        FileUtils.mkdir_p('test-app')
        FileUtils.mkdir_p('test-app/server/handlers')
        FileUtils.touch('test-app/.git')
        FileUtils.touch('test-app/.github')
        FileUtils.touch('test-app/server/handlers/client.js')
        FileUtils.touch('test-app/server/handlers/client.cli.js')

        @context.stubs(:uname).returns('Mac')
        expect_node_npm_check_commands
        @context.expects(:capture2).with('npm config get @shopify:registry').returns(
          ['https://badregistry.com', nil]
        )
        ShopifyCli::Git.expects(:clone).with('https://github.com/Shopify/shopify-app-node.git', 'test-app')
        @context.expects(:system).with(
          'npm',
          '--userconfig',
          './.npmrc',
          'config',
          'set',
          '@shopify:registry',
          'https://registry.yarnpkg.com',
          chdir: @context.root + '/test-app'
        )
        ShopifyCli::JsDeps.expects(:install)

        stub_partner_req(
          'create_app',
          variables: {
            org: 42,
            title: 'test-app',
            type: 'public',
            app_url: 'https://shopify.github.io/shopify-app-cli/getting-started',
            redir: ["http://127.0.0.1:3456"],
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
          --name=test-app \
          --type=public \
          --organization_id=42 \
          --shop_domain=testshop.myshopify.com")
      end

      def expect_node_npm_check_commands
        @context.expects(:capture2e).with('which', 'node').returns(['/usr/bin/node', mock(success?: true)])
        @context.expects(:capture2e).with('node', '-v').returns(['8.0.0', mock(success?: true)])
        @context.expects(:capture2e).with('which', 'npm').returns(['/usr/bin/npm', mock(success?: true)])
        @context.expects(:capture2e).with('npm', '-v').returns(['1', mock(success?: true)])
      end
    end
  end
end
