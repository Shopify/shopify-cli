# frozen_string_literal: true
require "project_types/php/test_helper"
require "semantic/semantic"

module PHP
  module Commands
    class CreateTest < MiniTest::Test
      include TestHelpers::Partners
      include TestHelpers::FakeUI

      ENV_FILE = <<~CONTENT
        SHOPIFY_API_KEY=newapikey
        SHOPIFY_API_SECRET=secret
        SHOP=testshop.myshopify.com
        SCOPES=read_products
        HOST=localhost
        DB_DATABASE=storage/db.sqlite
      CONTENT

      FINAL_ENV_FILE = <<~CONTENT
        SHOPIFY_API_KEY=newapikey
        SHOPIFY_API_SECRET=secret
        SHOP=testshop.myshopify.com
        SCOPES=write_products,write_draft_orders,write_customers
        HOST=localhost
        DB_DATABASE=#{ShopifyCLI::ROOT}/test/fixtures/project/test-app/storage/db.sqlite
      CONTENT

      SHOPIFYCLI_FILE = <<~APPTYPE
        ---
        project_type: php
        organization_id: 42
      APPTYPE

      def test_prints_help_with_no_name_argument
        io = capture_io { run_cmd("php create --help") }
        assert_message_output(io: io, expected_content: [PHP::Command::Create.help])
      end

      def test_check_php_installed
        @context.expects(:which).with("php").returns(nil)
        assert_raises ShopifyCLI::Abort, "php.create.error.php_required" do
          perform_command
        end
      end

      def test_check_get_php_version
        @context.expects(:which).with("php").returns("/usr/bin/php")
        @context.expects(:capture2e).with("php", "-r", "echo phpversion();").returns([nil, mock(success?: false)])
        assert_raises ShopifyCLI::Abort, "php.create.error.php_version_failure" do
          perform_command
        end
      end

      def test_check_composer_installed
        @context.expects(:which).with("php").returns("/usr/bin/php")
        @context.expects(:which).with("composer").returns(nil)
        assert_raises ShopifyCLI::Abort, "php.create.error.composer_required" do
          perform_command
        end
      end

      def test_can_create_new_app
        create_test_app_directory_structure

        @context.stubs(:uname).returns("Mac")
        expect_php_composer_check_commands

        expect_npm_check_commands
        @context.expects(:capture2).with("npm config get @shopify:registry").returns(
          ["https://registry.yarnpkg.com", nil]
        )

        ShopifyCLI::Git.expects(:clone).with("https://github.com/Shopify/shopify-app-php.git", "test-app")
        ShopifyCLI::PHPDeps.expects(:install)
        ShopifyCLI::JsDeps.expects(:install)
        @context.expects(:system).with("php", "artisan", "key:generate")
        @context.expects(:system).with("php", "artisan", "migrate")

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

        perform_command

        @context.chdir("..")

        assert_equal SHOPIFYCLI_FILE, File.read("test-app/.shopify-cli.yml")
        assert_equal FINAL_ENV_FILE, File.read("test-app/.env")
        refute File.exist?("test-app/.git")
        refute File.exist?("test-app/.github")
        assert File.exist?("test-app/.env")
        assert File.exist?("test-app/storage/db.sqlite")

        FileUtils.rm_r("test-app")
      end

      private

      def perform_command
        run_cmd("php create \
          --name=test-app \
          --type=public \
          --organization-id=42 \
          --store=testshop.myshopify.com")
      end

      def expect_php_composer_check_commands
        @context.expects(:which).with("php").returns("/usr/bin/php")
        @context.expects(:capture2e).with("php", "-r", "echo phpversion();").returns(["8.0.0", mock(success?: true)])
        @context.expects(:which).with("composer").returns("/usr/bin/composer")
      end

      def expect_npm_check_commands
        @context.expects(:which).with("npm").returns("/usr/bin/npm")
        @context.expects(:capture2e).with("npm", "-v").returns(["1", mock(success?: true)])
      end

      def create_test_app_directory_structure
        FileUtils.mkdir_p("test-app/storage")
        FileUtils.touch(File.join("test-app/.git"))
        FileUtils.touch(File.join("test-app/.github"))
        File.write("test-app/.env.example", ENV_FILE)
      end
    end
  end
end
