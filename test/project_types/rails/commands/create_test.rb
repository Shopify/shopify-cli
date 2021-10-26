# frozen_string_literal: true
require "project_types/rails/test_helper"
require "semantic/semantic"

module Rails
  module Commands
    class CreateTest < MiniTest::Test
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
        project_type: rails
        organization_id: 42
      APPTYPE

      def setup
        super
        ShopifyCLI::Tasks::EnsureAuthenticated.stubs(:call)
        ShopifyCLI::Shopifolk.stubs(:acting_as_shopify_organization?).returns(false)
      end

      def test_prints_help_with_no_name_argument
        io = capture_io { run_cmd("rails create --help") }
        assert_match(CLI::UI.fmt(Rails::Command::Create.help), io.join)
      end

      def test_will_abort_if_bad_ruby
        Ruby.expects(:version).returns(Semantic::Version.new("2.3.7"))
        assert_raises ShopifyCLI::Abort do
          perform_command
        end

        Ruby.expects(:version).returns(Semantic::Version.new("3.1.0"))
        assert_raises ShopifyCLI::Abort do
          perform_command
        end
      end

      def test_can_create_new_app
        create_mock_dirs

        gem_path = create_gem_path_and_binaries
        Gem.stubs(:gem_home).returns(gem_path)

        Ruby.expects(:version).returns(Semantic::Version.new("2.5.0"))
        Gem.expects(:install).with(@context, "rails", "<6.1").returns(true)
        Gem.expects(:install).with(@context, "bundler", "~>2.0").returns(true)
        expect_command(%W(#{gem_path}/bin/rails new --skip-spring --database=sqlite3 test-app))
        expect_command(%W(#{gem_path}/bin/bundle install),
          chdir: File.join(@context.root, "test-app"))
        expect_command(%W(#{gem_path}/bin/rails generate shopify_app --new-shopify-cli-app),
          chdir: File.join(@context.root, "test-app"))
        expect_command(%W(#{gem_path}/bin/rails db:create),
          chdir: File.join(@context.root, "test-app"))
        expect_command(%W(#{gem_path}/bin/rails db:migrate RAILS_ENV=development),
          chdir: File.join(@context.root, "test-app"))
        expect_command(%W(#{gem_path}/bin/rails webpacker:install),
          chdir: File.join(@context.root, "test-app"))

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

        assert_equal SHOPIFYCLI_FILE, File.read("test-app/.shopify-cli.yml")
        assert_equal ENV_FILE, File.read("test-app/.env")
        assert_equal Rails::Command::Create::USER_AGENT_CODE, File.read("test-app/config/initializers/user_agent.rb")

        delete_gem_path_and_binaries
        FileUtils.rm_r("test-app")
      end

      def test_can_create_new_app_with_db_flag
        create_mock_dirs

        gem_path = create_gem_path_and_binaries
        Gem.stubs(:gem_home).returns(gem_path)

        Ruby.expects(:version).returns(Semantic::Version.new("2.5.0"))
        Gem.expects(:install).with(@context, "rails", "<6.1").returns(true)
        Gem.expects(:install).with(@context, "bundler", "~>2.0").returns(true)
        expect_command(%W(#{gem_path}/bin/rails new --skip-spring --database=postgresql test-app))
        expect_command(%W(#{gem_path}/bin/bundle install),
          chdir: File.join(@context.root, "test-app"))
        expect_command(%W(#{gem_path}/bin/rails generate shopify_app --new-shopify-cli-app),
          chdir: File.join(@context.root, "test-app"))
        expect_command(%W(#{gem_path}/bin/rails db:create),
          chdir: File.join(@context.root, "test-app"))
        expect_command(%W(#{gem_path}/bin/rails db:migrate RAILS_ENV=development),
          chdir: File.join(@context.root, "test-app"))
        expect_command(%W(#{gem_path}/bin/rails webpacker:install),
          chdir: File.join(@context.root, "test-app"))

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

        perform_command("--db=postgresql")

        delete_gem_path_and_binaries
        FileUtils.rm_r("test-app")
      end

      def test_can_create_new_app_with_rails_opts_flag
        create_mock_dirs

        gem_path = create_gem_path_and_binaries
        Gem.stubs(:gem_home).returns(gem_path)

        Ruby.expects(:version).returns(Semantic::Version.new("2.5.0"))
        Gem.expects(:install).with(@context, "rails", "<6.1").returns(true)
        Gem.expects(:install).with(@context, "bundler", "~>2.0").returns(true)
        expect_command(%W(#{gem_path}/bin/rails new --skip-spring --database=sqlite3 --edge -J test-app))
        expect_command(%W(#{gem_path}/bin/bundle install),
          chdir: File.join(@context.root, "test-app"))
        expect_command(%W(#{gem_path}/bin/rails generate shopify_app --new-shopify-cli-app),
          chdir: File.join(@context.root, "test-app"))
        expect_command(%W(#{gem_path}/bin/rails db:create),
          chdir: File.join(@context.root, "test-app"))
        expect_command(%W(#{gem_path}/bin/rails db:migrate RAILS_ENV=development),
          chdir: File.join(@context.root, "test-app"))
        expect_command(%W(#{gem_path}/bin/rails webpacker:install),
          chdir: File.join(@context.root, "test-app"))

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

        perform_command("--rails-opts=--edge -J")

        delete_gem_path_and_binaries
        FileUtils.rm_r("test-app")
      end

      def test_create_fails_if_path_exists
        FileUtils.mkdir_p("test-app")
        FileUtils.mkdir_p("test-app/config/initializers")

        gem_path = create_gem_path_and_binaries
        Gem.stubs(:gem_home).returns(gem_path)

        Ruby.expects(:version).returns(Semantic::Version.new("2.5.0"))
        Gem.expects(:install).with(@context, "rails", "<6.1").returns(true)
        Gem.expects(:install).with(@context, "bundler", "~>2.0").returns(true)
        Dir.stubs(:exist?).returns(true)

        exception = assert_raises ShopifyCLI::Abort do
          perform_command
        end
        assert_equal(
          "{{x}} " + @context.message("rails.create.error.dir_exists", "test-app"),
          exception.message
        )

        delete_gem_path_and_binaries
        FileUtils.rm_r("test-app")
      end

      private

      def expect_command(command, chdir: @context.root)
        process_status = stub("process_status", success?: true)
        @context.expects(:system).with(*command, chdir: chdir).returns(process_status)
      end

      def perform_command_snake_case(add_cmd = nil)
        default_new_cmd = %w(rails create \
                             --type=public \
                             --name=test-app \
                             --organization_id=42 \
                             --db=sqlite3 \
                             --shop_domain=testshop.myshopify.com)
        run_cmd(default_new_cmd << add_cmd, false)
      end

      def perform_command(add_cmd = nil)
        default_new_cmd = %w(rails create \
                             --type=public \
                             --name=test-app \
                             --organization-id=42 \
                             --db=sqlite3 \
                             --shop-domain=testshop.myshopify.com)
        run_cmd(default_new_cmd << add_cmd, false)
      end

      def create_gem_path_and_binaries
        FileUtils.mkdir_p("gem/path/bin")
        gem_path = File.expand_path("gem/path")
        ["bundle", "rails"].each do |f|
          FileUtils.touch("#{gem_path}/bin/#{f}")
        end
        gem_path
      end

      def delete_gem_path_and_binaries
        FileUtils.rm_r("gem")
      end

      def create_mock_dirs
        FileUtils.mkdir_p("test-app")
        FileUtils.mkdir_p("test-app/config/initializers")

        # The dir needs to exist to simulate the command working, but we don't want to fail on the pre-create check
        Dir.expects(:exist?).with(File.join(@context.root, "test-app")).returns(false)
        Dir.stubs(:exist?).with(File.join(ShopifyCLI::ROOT, "test")).returns(true)
      end
    end
  end
end
