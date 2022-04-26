require "semantic/semantic"

module ShopifyCLI
  module Services
    module App
      module Create
        class RailsService < BaseService
          USER_AGENT_CODE = <<~USERAGENT
            module ShopifyAPI
              class Base < ActiveResource::Base
                self.headers['User-Agent'] << " | ShopifyApp/\#{ShopifyApp::VERSION} | Shopify CLI"
              end
            end
          USERAGENT

          DEFAULT_RAILS_FLAGS = %w(--skip-spring)

          attr_reader :name, :organization_id, :store_domain, :type, :db, :rails_opts, :context

          def initialize(name:, organization_id:, store_domain:, type:, db:, rails_opts:, context:)
            @name = name
            @organization_id = organization_id
            @store_domain = store_domain
            @type = type
            @db = db
            @rails_opts = rails_opts
            @context = context
            super()
          end

          def call
            form_options = {
              name: name,
              organization_id: organization_id,
              shop_domain: store_domain,
              type: type,
            }
            form_options[:db] = db unless db.nil?
            form_options[:rails_opts] = rails_opts unless rails_opts.nil?
            form = form_data(form_options)

            raise ShopifyCLI::AbortSilent if form.nil?

            check_dependencies

            build(form.name, form.db)
            set_custom_ua
            ShopifyCLI::Project.write(
              context,
              project_type: "rails",
              organization_id: form.organization_id,
            )

            api_client = if ShopifyCLI::Environment.acceptance_test?
              {
                "apiKey" => "public_api_key",
                "apiSecretKeys" => [
                  {
                    "secret" => "api_secret_key",
                  },
                ],
              }
            else
              ShopifyCLI::Tasks::CreateApiClient.call(
                context,
                org_id: form.organization_id,
                title: form.name,
                type: form.type,
              )
            end

            ShopifyCLI::Resources::EnvFile.new(
              api_key: api_client["apiKey"],
              secret: api_client["apiSecretKeys"].first["secret"],
              shop: form.shop_domain,
              scopes: "write_products,write_customers,write_draft_orders",
            ).write(context)

            partners_url = ShopifyCLI::PartnersAPI.partners_url_for(form.organization_id, api_client["id"])

            context.puts(context.message("apps.create.info.created", form.name, partners_url))
            context.puts(context.message("apps.create.info.serve", form.name, ShopifyCLI::TOOL_NAME))
            unless ShopifyCLI::Shopifolk.acting_as_shopify_organization?
              context.puts(context.message("apps.create.info.install", partners_url, form.name))
            end
          end

          private

          def form_data(form_options)
            if ShopifyCLI::Environment.acceptance_test?
              Struct.new(:name, :organization_id, :type, :shop_domain, :db, keyword_init: true).new(
                name: form_options[:name],
                organization_id: "123",
                shop_domain: "test.shopify.io",
                type: "public",
                db: form_options[:db]
              )
            else
              Rails::Forms::Create.ask(context, [], form_options)
            end
          end

          def check_dependencies
            check_ruby
            check_node
            check_yarn
          end

          def check_ruby
            ruby_version = Environment.ruby_version(context: context)
            return if ruby_version.satisfies?("~>2.5") ||
              ruby_version.satisfies?("~>3.0.0") ||
              ruby_version.satisfies?("~>3.1.0")
            context.abort(context.message("core.app.create.rails.error.invalid_ruby_version"))
          end

          def check_node
            cmd_path = context.which("node")
            if cmd_path.nil?
              context.abort(context.message("core.app.create.rails.error.node_required")) unless context.windows?
              context.puts("{{x}} {{red:" + context.message("core.app.create.rails.error.node_required") + "}}")
              context.puts(context.message("core.app.create.rails.info.open_new_shell", "node"))
              raise ShopifyCLI::AbortSilent
            end

            version, stat = context.capture2e("node", "-v")
            unless stat.success?
              context.abort(context.message("core.app.create.rails.error.node_version_failure")) unless context.windows?
              # execution stops above if not Windows
              context.puts("{{x}} {{red:" + context.message("core.app.create.rails.error.node_version_failure") + "}}")
              context.puts(context.message("core.app.create.rails.info.open_new_shell", "node"))
              raise ShopifyCLI::AbortSilent
            end

            context.done(context.message("core.app.create.rails.node_version", version))
          end

          def check_yarn
            cmd_path = context.which("yarn")
            if cmd_path.nil?
              context.abort(context.message("core.app.create.rails.error.yarn_required")) unless context.windows?
              context.puts("{{x}} {{red:" + context.message("core.app.create.rails.error.yarn_required") + "}}")
              context.puts(context.message("core.app.create.rails.info.open_new_shell", "yarn"))
              raise ShopifyCLI::AbortSilent
            end

            version, stat = context.capture2e("yarn", "-v")
            unless stat.success?
              context.abort(context.message("core.app.create.rails.error.yarn_version_failure")) unless context.windows?
              context.puts("{{x}} {{red:" + context.message("core.app.create.rails.error.yarn_version_failure") + "}}")
              context.puts(context.message("core.app.create.rails.info.open_new_shell", "yarn"))
              raise ShopifyCLI::AbortSilent
            end

            context.done(context.message("core.app.create.rails.yarn_version", version))
          end

          def build(name, db)
            unless install_gem("rails")
              context.abort(context.message("core.app.create.rails.error.install_failure", "rails"))
            end

            unless install_gem("bundler", "~>2.0")
              context.abort(context.message("core.app.create.rails.error.install_failure", "bundler ~>2.0"))
            end

            full_path = File.join(context.root, name)
            context.abort(context.message("core.app.create.rails.error.dir_exists", name)) if Dir.exist?(full_path)

            CLI::UI::Frame.open(context.message("core.app.create.rails.generating_app", name)) do
              new_command = %w(rails new)
              new_command << name
              new_command += DEFAULT_RAILS_FLAGS
              new_command << "--database=#{db}"
              new_command += rails_opts.split unless rails_opts.nil?

              syscall(new_command)
            end

            context.root = full_path

            File.open(File.join(context.root, ".gitignore"), "a") { |f| f.write(".env") }

            context.puts(context.message("core.app.create.rails.adding_shopify_gem"))
            File.open(File.join(context.root, "Gemfile"), "a") do |f|
              f.puts "\ngem 'shopify_app', '~>19.0.1'"
            end
            CLI::UI::Frame.open(context.message("core.app.create.rails.running_bundle_install")) do
              syscall(%w(bundle install))
            end

            CLI::UI::Frame.open(context.message("core.app.create.rails.running_generator")) do
              syscall(%w(rails generate shopify_app --new-shopify-cli-app))
            end

            CLI::UI::Frame.open(context.message("core.app.create.rails.running_migrations")) do
              syscall(%w(rails db:create))
              syscall(%w(rails db:migrate RAILS_ENV=development))
            end

            if install_webpacker?
              CLI::UI::Frame.open(context.message("core.app.create.rails.running_webpacker_install")) do
                syscall(%w(rails webpacker:install))
              end
            end
          end

          def set_custom_ua
            requires_ua_file = Dir.chdir(context.root) do
              context.ruby_gem_version("shopify_app") < ::Semantic::Version.new("19.0.0")
            end

            return unless requires_ua_file

            ua_path = File.join("config", "initializers", "user_agent.rb")
            context.write(ua_path, USER_AGENT_CODE)
          end

          def syscall(args)
            args[0] = Rails::Gem.binary_path_for(context, args[0])
            context.system(*args, chdir: context.root)
          end

          def install_gem(name, version = nil)
            Rails::Gem.install(context, name, version)
          end

          def install_webpacker?
            rails_version = Environment.rails_version(context: context)
            webpacker_config = File.exist?(File.join(context.root, "config/webpacker.yml"))

            rails_version < ::Semantic::Version.new("7.0.0") && !webpacker_config
          end
        end
      end
    end
  end
end
