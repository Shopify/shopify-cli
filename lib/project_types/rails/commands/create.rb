# frozen_string_literal: true
module Rails
  class Command
    class Create < ShopifyCLI::Command::AppSubCommand
      unless ShopifyCLI::Environment.acceptance_test?
        prerequisite_task :ensure_authenticated
      end

      USER_AGENT_CODE = <<~USERAGENT
        module ShopifyAPI
          class Base < ActiveResource::Base
            self.headers['User-Agent'] << " | ShopifyApp/\#{ShopifyApp::VERSION} | Shopify CLI"
          end
        end
      USERAGENT

      DEFAULT_RAILS_FLAGS = %w(--skip-spring)

      options do |parser, flags|
        # backwards compatibility allow 'title' for now
        parser.on("--title=TITLE") { |t| flags[:title] = t }
        parser.on("--name=NAME") { |t| flags[:title] = t }
        parser.on("--organization_id=ID") { |id| flags[:organization_id] = id }
        parser.on("--organization-id=ID") { |id| flags[:organization_id] = id }
        parser.on("--store=MYSHOPIFYDOMAIN") { |url| flags[:shop_domain] = url }
        # backwards compatibility allow 'shop domain' for now
        parser.on("--shop_domain=MYSHOPIFYDOMAIN") { |url| flags[:shop_domain] = url }
        parser.on("--shop-domain=MYSHOPIFYDOMAIN") { |url| flags[:shop_domain] = url }
        parser.on("--type=APPTYPE") { |type| flags[:type] = type }
        parser.on("--db=DB") { |db| flags[:db] = db }
        parser.on("--rails_opts=RAILSOPTS") { |opts| flags[:rails_opts] = opts }
        parser.on("--rails-opts=RAILSOPTS") { |opts| flags[:rails_opts] = opts }
      end

      def call(args, _name)
        form_data = self.form_data(args)
        return @ctx.puts(self.class.help) if form_data.nil?

        ruby_version = Ruby.version(@ctx)
        @ctx.abort(@ctx.message("rails.create.error.invalid_ruby_version")) unless
          ruby_version.satisfies?("~>2.5") || ruby_version.satisfies?("~>3.0.0")

        check_node
        check_yarn

        build(form_data.name, form_data.db)

        set_custom_ua
        ShopifyCLI::Project.write(
          @ctx,
          project_type: "rails",
          organization_id: form_data.organization_id,
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
            @ctx,
            org_id: form_data.organization_id,
            title: form_data.title,
            type: form_data.type,
          )
        end

        ShopifyCLI::Resources::EnvFile.new(
          api_key: api_client["apiKey"],
          secret: api_client["apiSecretKeys"].first["secret"],
          shop: form_data.shop_domain,
          scopes: "write_products,write_customers,write_draft_orders",
        ).write(@ctx)

        partners_url = ShopifyCLI::PartnersAPI.partners_url_for(form_data.organization_id, api_client["id"])

        @ctx.puts(@ctx.message("apps.create.info.created", form_data.title, partners_url))
        @ctx.puts(@ctx.message("apps.create.info.serve", form_data.name, ShopifyCLI::TOOL_NAME, "rails"))
        unless ShopifyCLI::Shopifolk.acting_as_shopify_organization?
          @ctx.puts(@ctx.message("apps.create.info.install", partners_url, form_data.title))
        end
      end

      def form_data(args)
        if ShopifyCLI::Environment.acceptance_test?
          Struct.new(:title, :name, :organization_id, :type, :shop_domain, :db, keyword_init: true).new(
            title: options.flags[:title],
            name: options.flags[:title],
            organization_id: "123",
            shop_domain: "test.shopify.io",
            type: "public",
            db: options.flags[:db]
          )
        else
          Forms::Create.ask(@ctx, args, options.flags)
        end
      end

      def self.help
        ShopifyCLI::Context.message("rails.create.help", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
      end

      private

      def check_node
        cmd_path = @ctx.which("node")
        if cmd_path.nil?
          @ctx.abort(@ctx.message("rails.create.error.node_required")) unless @ctx.windows?
          @ctx.puts("{{x}} {{red:" + @ctx.message("rails.create.error.node_required") + "}}")
          @ctx.puts(@ctx.message("rails.create.info.open_new_shell", "node"))
          raise ShopifyCLI::AbortSilent
        end

        version, stat = @ctx.capture2e("node", "-v")
        unless stat.success?
          @ctx.abort(@ctx.message("rails.create.error.node_version_failure")) unless @ctx.windows?
          # execution stops above if not Windows
          @ctx.puts("{{x}} {{red:" + @ctx.message("rails.create.error.node_version_failure") + "}}")
          @ctx.puts(@ctx.message("rails.create.info.open_new_shell", "node"))
          raise ShopifyCLI::AbortSilent
        end

        @ctx.done(@ctx.message("rails.create.node_version", version))
      end

      def check_yarn
        cmd_path = @ctx.which("yarn")
        if cmd_path.nil?
          @ctx.abort(@ctx.message("rails.create.error.yarn_required")) unless @ctx.windows?
          @ctx.puts("{{x}} {{red:" + @ctx.message("rails.create.error.yarn_required") + "}}")
          @ctx.puts(@ctx.message("rails.create.info.open_new_shell", "yarn"))
          raise ShopifyCLI::AbortSilent
        end

        version, stat = @ctx.capture2e("yarn", "-v")
        unless stat.success?
          @ctx.abort(@ctx.message("rails.create.error.yarn_version_failure")) unless @ctx.windows?
          @ctx.puts("{{x}} {{red:" + @ctx.message("rails.create.error.yarn_version_failure") + "}}")
          @ctx.puts(@ctx.message("rails.create.info.open_new_shell", "yarn"))
          raise ShopifyCLI::AbortSilent
        end

        @ctx.done(@ctx.message("rails.create.yarn_version", version))
      end

      def build(name, db)
        @ctx.abort(@ctx.message("rails.create.error.install_failure", "rails")) unless install_gem("rails", "<6.1")
        @ctx.abort(@ctx.message("rails.create.error.install_failure", "bundler ~>2.0")) unless
          install_gem("bundler", "~>2.0")

        full_path = File.join(@ctx.root, name)
        @ctx.abort(@ctx.message("rails.create.error.dir_exists", name)) if Dir.exist?(full_path)

        CLI::UI::Frame.open(@ctx.message("rails.create.generating_app", name)) do
          new_command = %w(rails new)
          new_command += DEFAULT_RAILS_FLAGS
          new_command << "--database=#{db}"
          new_command += options.flags[:rails_opts].split unless options.flags[:rails_opts].nil?
          new_command << name

          syscall(new_command)
        end

        @ctx.root = full_path

        File.open(File.join(@ctx.root, ".gitignore"), "a") { |f| f.write(".env") }

        @ctx.puts(@ctx.message("rails.create.adding_shopify_gem"))
        File.open(File.join(@ctx.root, "Gemfile"), "a") do |f|
          f.puts "\ngem 'shopify_app', '>=17.0.3'"
        end
        CLI::UI::Frame.open(@ctx.message("rails.create.running_bundle_install")) do
          syscall(%w(bundle install))
        end

        CLI::UI::Frame.open(@ctx.message("rails.create.running_generator")) do
          syscall(%w(rails generate shopify_app --new-shopify-cli-app))
        end

        CLI::UI::Frame.open(@ctx.message("rails.create.running_migrations")) do
          syscall(%w(rails db:create))
          syscall(%w(rails db:migrate RAILS_ENV=development))
        end

        unless File.exist?(File.join(@ctx.root, "config/webpacker.yml"))
          CLI::UI::Frame.open(@ctx.message("rails.create.running_webpacker_install")) do
            syscall(%w(rails webpacker:install))
          end
        end
      end

      def set_custom_ua
        ua_path = File.join("config", "initializers", "user_agent.rb")
        @ctx.write(ua_path, USER_AGENT_CODE)
      end

      def syscall(args)
        args[0] = Gem.binary_path_for(@ctx, args[0])
        @ctx.system(*args, chdir: @ctx.root)
      end

      def install_gem(name, version = nil)
        Gem.install(@ctx, name, version)
      end
    end
  end
end
