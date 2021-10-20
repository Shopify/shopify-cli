require "test_helper"
require "semantic/semantic"
require "project_types/rails/test_helper"

module ShopifyCLI
  module Services
    module App
      module Create
        class RailsServiceTest < MiniTest::Test
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

          def test_will_abort_if_bad_ruby
            ::Rails::Ruby.expects(:version).returns(Semantic::Version.new("2.3.7"))
            assert_raises ShopifyCLI::Abort do
              call_service
            end

            ::Rails::Ruby.expects(:version).returns(Semantic::Version.new("3.1.0"))
            assert_raises ShopifyCLI::Abort do
              call_service
            end
          end

          def test_can_create_new_app
            create_mock_dirs

            gem_path = create_gem_path_and_binaries
            ::Rails::Gem.stubs(:gem_home).returns(gem_path)

            ::Rails::Ruby.expects(:version).returns(Semantic::Version.new("2.5.0"))
            ::Rails::Gem.expects(:install).with(@context, "rails", "<6.1").returns(true)
            ::Rails::Gem.expects(:install).with(@context, "bundler", "~>2.0").returns(true)
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

            call_service

            assert_equal SHOPIFYCLI_FILE, File.read("test-app/.shopify-cli.yml")
            assert_equal ENV_FILE, File.read("test-app/.env")
            assert_equal RailsService::USER_AGENT_CODE, File.read("test-app/config/initializers/user_agent.rb")

            delete_gem_path_and_binaries
            FileUtils.rm_r("test-app")
          end

          def test_can_create_new_app_with_db_flag
            create_mock_dirs

            gem_path = create_gem_path_and_binaries
            ::Rails::Gem.stubs(:gem_home).returns(gem_path)

            ::Rails::Ruby.expects(:version).returns(Semantic::Version.new("2.5.0"))
            ::Rails::Gem.expects(:install).with(@context, "rails", "<6.1").returns(true)
            ::Rails::Gem.expects(:install).with(@context, "bundler", "~>2.0").returns(true)
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

            call_service(db: "postgresql")

            delete_gem_path_and_binaries
            FileUtils.rm_r("test-app")
          end

          def test_can_create_new_app_with_rails_opts_flag
            create_mock_dirs

            gem_path = create_gem_path_and_binaries
            ::Rails::Gem.stubs(:gem_home).returns(gem_path)

            ::Rails::Ruby.expects(:version).returns(Semantic::Version.new("2.5.0"))
            ::Rails::Gem.expects(:install).with(@context, "rails", "<6.1").returns(true)
            ::Rails::Gem.expects(:install).with(@context, "bundler", "~>2.0").returns(true)
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

            call_service(rails_opts: "--edge -J")

            delete_gem_path_and_binaries
            FileUtils.rm_r("test-app")
          end

          def test_create_fails_if_path_exists
            FileUtils.mkdir_p("test-app")
            FileUtils.mkdir_p("test-app/config/initializers")

            gem_path = create_gem_path_and_binaries
            ::Rails::Gem.stubs(:gem_home).returns(gem_path)

            ::Rails::Ruby.expects(:version).returns(Semantic::Version.new("2.5.0"))
            ::Rails::Gem.expects(:install).with(@context, "rails", "<6.1").returns(true)
            ::Rails::Gem.expects(:install).with(@context, "bundler", "~>2.0").returns(true)
            Dir.stubs(:exist?).returns(true)

            exception = assert_raises ShopifyCLI::Abort do
              call_service
            end
            assert_equal(
              "{{x}} " + @context.message("core.app.create.rails.error.dir_exists", "test-app"),
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

          def call_service(db: "sqlite3", rails_opts: nil)
            RailsService.call(
              name: "test-app",
              organization_id: "42",
              store: "testshop.myshopify.com",
              type: "public",
              db: db,
              rails_opts: rails_opts,
              context: @context
            )
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
  end
end
