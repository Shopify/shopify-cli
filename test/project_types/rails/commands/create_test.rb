# frozen_string_literal: true
require 'project_types/rails/test_helper'
require 'semantic/semantic'

module Rails
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
        project_type: rails
        organization_id: 42
      APPTYPE

      def test_prints_help_with_no_name_argument
        io = capture_io { run_cmd('create rails --help') }
        assert_match(CLI::UI.fmt(Rails::Commands::Create.help), io.join)
      end

      def test_will_abort_if_bad_ruby
        Ruby.expects(:version).returns(Semantic::Version.new('2.3.7'))
        assert_raises ShopifyCli::Abort do
          perform_command
        end
      end

      def test_can_create_new_app
        FileUtils.mkdir_p('test-app')
        FileUtils.mkdir_p('test-app/config/initializers')

        gem_path = "/gem/path/"
        Gem.stubs(:gem_home).returns(gem_path)

        Ruby.expects(:version).returns(Semantic::Version.new('2.4.0'))
        Gem.expects(:install).with(@context, 'rails', nil)
        Gem.expects(:install).with(@context, 'bundler', '~>1.0')
        Gem.expects(:install).with(@context, 'bundler', '~>2.0')
        expect_command(%w(/gem/path/bin/rails new --skip-spring --database=sqlite3 test-app))
        expect_command(%w(/gem/path/bin/bundle install),
                       chdir: File.join(@context.root, 'test-app'))
        expect_command(%w(/gem/path/bin/spring stop),
                       chdir: File.join(@context.root, 'test-app'))
        expect_command(%w(/gem/path/bin/rails generate shopify_app),
                       chdir: File.join(@context.root, 'test-app'))
        expect_command(%w(/gem/path/bin/rails db:create),
                       chdir: File.join(@context.root, 'test-app'))
        expect_command(%w(/gem/path/bin/rails db:migrate RAILS_ENV=development),
                       chdir: File.join(@context.root, 'test-app'))

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
        assert_equal Create::USER_AGENT_CODE, File.read("test-app/config/initializers/user_agent.rb")

        FileUtils.rm_r('test-app')
      end

      def test_can_create_new_app_with_db_flag
        FileUtils.mkdir_p('test-app')
        FileUtils.mkdir_p('test-app/config/initializers')

        gem_path = "/gem/path/"
        Gem.stubs(:gem_home).returns(gem_path)

        Ruby.expects(:version).returns(Semantic::Version.new('2.4.0'))
        Gem.expects(:install).with(@context, 'rails', nil)
        Gem.expects(:install).with(@context, 'bundler', '~>1.0')
        Gem.expects(:install).with(@context, 'bundler', '~>2.0')
        expect_command(%w(/gem/path/bin/rails new --skip-spring --database=postgresql test-app))
        expect_command(%w(/gem/path/bin/bundle install),
                       chdir: File.join(@context.root, 'test-app'))
        expect_command(%w(/gem/path/bin/spring stop),
                       chdir: File.join(@context.root, 'test-app'))
        expect_command(%w(/gem/path/bin/rails generate shopify_app),
                       chdir: File.join(@context.root, 'test-app'))
        expect_command(%w(/gem/path/bin/rails db:create),
                       chdir: File.join(@context.root, 'test-app'))
        expect_command(%w(/gem/path/bin/rails db:migrate RAILS_ENV=development),
                       chdir: File.join(@context.root, 'test-app'))

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

        perform_command('--db=postgresql')

        FileUtils.rm_r('test-app')
      end

      def test_can_create_new_app_with_rails_opts_flag
        FileUtils.mkdir_p('test-app')
        FileUtils.mkdir_p('test-app/config/initializers')

        gem_path = "/gem/path/"
        Gem.stubs(:gem_home).returns(gem_path)

        Ruby.expects(:version).returns(Semantic::Version.new('2.4.0'))
        Gem.expects(:install).with(@context, 'rails', nil)
        Gem.expects(:install).with(@context, 'bundler', '~>1.0')
        Gem.expects(:install).with(@context, 'bundler', '~>2.0')
        expect_command(%w(/gem/path/bin/rails new --skip-spring --database=sqlite3 --edge -J test-app))
        expect_command(%w(/gem/path/bin/bundle install),
                       chdir: File.join(@context.root, 'test-app'))
        expect_command(%w(/gem/path/bin/spring stop),
                       chdir: File.join(@context.root, 'test-app'))
        expect_command(%w(/gem/path/bin/rails generate shopify_app),
                       chdir: File.join(@context.root, 'test-app'))
        expect_command(%w(/gem/path/bin/rails db:create),
                       chdir: File.join(@context.root, 'test-app'))
        expect_command(%w(/gem/path/bin/rails db:migrate RAILS_ENV=development),
                       chdir: File.join(@context.root, 'test-app'))

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

        perform_command('--rails-opts=--edge -J')

        FileUtils.rm_r('test-app')
      end

      private

      def expect_command(command, chdir: @context.root)
        @context.expects(:system).with(*command, chdir: chdir)
      end

      def perform_command(add_cmd = nil)
        default_new_cmd = %w(create rails \
                             --type=public \
                             --name=test-app \
                             --organization_id=42 \
                             --db=sqlite3 \
                             --shop_domain=testshop.myshopify.com)
        run_cmd(default_new_cmd << add_cmd, false)
      end
    end
  end
end
