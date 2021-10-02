# frozen_string_literal: true
require "semantic/semantic"

module PHP
  class Command
    class Create < ShopifyCLI::Command::AppSubCommand
      options do |parser, flags|
        parser.on("--name=NAME") { |name| flags[:title] = name }
        parser.on("--organization-id=ID") { |organization_id| flags[:organization_id] = organization_id }
        parser.on("--store=MYSHOPIFYDOMAIN") { |url| flags[:shop_domain] = url }
        parser.on("--type=APPTYPE") { |type| flags[:type] = type }
        parser.on("--verbose") { flags[:verbose] = true }
      end

      def call(args, _name)
        form = Forms::Create.ask(@ctx, args, options.flags)
        return @ctx.puts(self.class.help) if form.nil?

        check_php
        check_composer
        check_npm
        app_id = build(form)

        ShopifyCLI::Project.write(
          @ctx,
          project_type: "php",
          organization_id: form.organization_id,
        )

        partners_url = ShopifyCLI::PartnersAPI.partners_url_for(form.organization_id, app_id)

        @ctx.puts(@ctx.message("apps.create.info.created", form.title, partners_url))
        @ctx.puts(@ctx.message("apps.create.info.serve", form.name, ShopifyCLI::TOOL_NAME, "php"))
        unless ShopifyCLI::Shopifolk.acting_as_shopify_organization?
          @ctx.puts(@ctx.message("apps.create.info.install", partners_url, form.title))
        end
      end

      def self.help
        ShopifyCLI::Context.message("php.create.help", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
      end

      private

      def check_php
        cmd_path = @ctx.which("php")
        @ctx.abort(@ctx.message("php.create.error.php_required")) if cmd_path.nil?

        version, stat = @ctx.capture2e("php", "-r", "echo phpversion();")
        @ctx.abort(@ctx.message("php.create.error.php_version_failure")) unless stat.success?

        if ::Semantic::Version.new(version) < ::Semantic::Version.new("7.3.0")
          @ctx.abort(@ctx.message("php.create.error.php_version_too_low", "7.3"))
        end

        @ctx.done(@ctx.message("php.create.php_version", version))
      end

      def check_composer
        cmd_path = @ctx.which("composer")
        @ctx.abort(@ctx.message("php.create.error.composer_required")) if cmd_path.nil?
      end

      def check_npm
        cmd_path = @ctx.which("npm")
        @ctx.abort(@ctx.message("php.create.error.npm_required")) if cmd_path.nil?

        version, stat = @ctx.capture2e("npm", "-v")
        @ctx.abort(@ctx.message("php.create.error.npm_version_failure")) unless stat.success?

        @ctx.done(@ctx.message("php.create.npm_version", version))
      end

      def build(form)
        ShopifyCLI::Git.clone("https://github.com/Shopify/shopify-app-php.git", form.name)

        @ctx.root = File.join(@ctx.root, form.name)
        @ctx.chdir(@ctx.root)

        api_client = ShopifyCLI::Tasks::CreateApiClient.call(
          @ctx,
          org_id: form.organization_id,
          title: form.title,
          type: form.type,
        )

        # Override the example settings with our own
        @ctx.cp(".env.example", ".env")

        env_file = ShopifyCLI::Resources::EnvFile.read
        env_file.api_key = api_client["apiKey"]
        env_file.secret = api_client["apiSecretKeys"].first["secret"]
        env_file.shop = form.shop_domain
        env_file.host = "localhost"
        env_file.scopes = "write_products,write_draft_orders,write_customers"
        env_file.extra["DB_DATABASE"] = File.join(@ctx.root, env_file.extra["DB_DATABASE"])
        env_file.write(@ctx)

        ShopifyCLI::PHPDeps.install(@ctx, !options.flags[:verbose].nil?)

        set_npm_config
        ShopifyCLI::JsDeps.install(@ctx, !options.flags[:verbose].nil?)

        title = @ctx.message("php.create.app_setting_up")
        success = @ctx.message("php.create.app_set_up")
        failure = @ctx.message("php.create.error.app_setup")
        CLI::UI::Frame.open(title, success_text: success, failure_text: failure) do
          FileUtils.touch(env_file.extra["DB_DATABASE"])
          @ctx.system("php", "artisan", "key:generate")
          @ctx.system("php", "artisan", "migrate")
        end

        begin
          @ctx.rm_r(".git")
          @ctx.rm_r(".github")
        rescue Errno::ENOENT => e
          @ctx.debug(e)
        end

        api_client["id"]
      end

      def set_npm_config
        # check available npmrc (either user or system) for production registry
        registry, _ = @ctx.capture2("npm config get @shopify:registry")
        return if registry.include?("https://registry.yarnpkg.com")

        # available npmrc doesn't have production registry =>
        # set a project-based .npmrc
        @ctx.system(
          "npm",
          "--userconfig",
          "./.npmrc",
          "config",
          "set",
          "@shopify:registry",
          "https://registry.yarnpkg.com",
          chdir: @ctx.root
        )
      end
    end
  end
end
