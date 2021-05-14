# frozen_string_literal: true
require "semantic/semantic"

module PHP
  module Commands
    class Create < ShopifyCli::SubCommand
      options do |parser, flags|
        parser.on("--name=NAME") { |name| flags[:title] = name }
        parser.on("--organization-id=ID") { |organization_id| flags[:organization_id] = organization_id }
        parser.on("--shop-domain=MYSHOPIFYDOMAIN") { |shop_domain| flags[:shop_domain] = shop_domain }
        parser.on("--type=APPTYPE") { |type| flags[:type] = type }
        parser.on("--verbose") { flags[:verbose] = true }
      end

      def call(args, _name)
        form = Forms::Create.ask(@ctx, args, options.flags)
        return @ctx.puts(self.class.help) if form.nil?

        check_php
        check_composer
        build(form.name)

        ShopifyCli::Project.write(
          @ctx,
          project_type: "php",
          organization_id: form.organization_id,
        )

        api_client = ShopifyCli::Tasks::CreateApiClient.call(
          @ctx,
          org_id: form.organization_id,
          title: form.title,
          type: form.type,
        )

        ShopifyCli::Resources::EnvFile.new(
          api_key: api_client["apiKey"],
          secret: api_client["apiSecretKeys"].first["secret"],
          shop: form.shop_domain,
          scopes: "write_products,write_customers,write_draft_orders",
        ).write(@ctx)

        partners_url = ShopifyCli::PartnersAPI.partners_url_for(form.organization_id, api_client["id"], local_debug?)

        @ctx.puts(@ctx.message("apps.create.info.created", form.title, partners_url))
        @ctx.puts(@ctx.message("apps.create.info.serve", form.name, ShopifyCli::TOOL_NAME))
        unless ShopifyCli::Shopifolk.acting_as_shopify_organization?
          @ctx.puts(@ctx.message("apps.create.info.install", partners_url, form.title))
        end
      end

      def self.help
        ShopifyCli::Context.message("php.create.help", ShopifyCli::TOOL_NAME, ShopifyCli::TOOL_NAME)
      end

      private

      def check_php
        cmd_path = @ctx.which("php")
        @ctx.abort(@ctx.message("php.create.error.php_required")) if cmd_path.nil?

        version, stat = @ctx.capture2e("php", "-r", "echo phpversion();")
        @ctx.abort(@ctx.message("php.create.error.php_version_failure")) unless stat.success?

        if ::Semantic::Version.new(version) < ::Semantic::Version.new('8.0.0')
          @ctx.abort(@ctx.message("php.create.error.php_version_too_low", '8.0'))
        end

        @ctx.done(@ctx.message("php.create.php_version", version))
      end

      def check_composer
        cmd_path = @ctx.which("composer")
        @ctx.abort(@ctx.message("php.create.error.composer_required")) if cmd_path.nil?
      end

      def build(name)
        ShopifyCli::Git.clone("https://github.com/Shopify/shopify-app-php.git", name)

        @ctx.root = File.join(@ctx.root, name)

        ShopifyCli::PHPDeps.install(@ctx, !options.flags[:verbose].nil?)

        begin
          @ctx.rm_r(".git")
          @ctx.rm_r(".github")
        rescue Errno::ENOENT => e
          @ctx.debug(e)
        end
      end

      def local_debug?
        @ctx.getenv(ShopifyCli::PartnersAPI::LOCAL_DEBUG)
      end
    end
  end
end
