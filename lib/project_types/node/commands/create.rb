# frozen_string_literal: true
module Node
  class Command
    class Create < ShopifyCLI::Command::AppSubCommand
      prerequisite_task :ensure_authenticated

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
        parser.on("--verbose") { flags[:verbose] = true }
      end

      def call(args, _name)
        form = Forms::Create.ask(@ctx, args, options.flags)
        return @ctx.puts(self.class.help) if form.nil?

        check_node
        check_npm
        build(form.name)

        ShopifyCLI::Project.write(
          @ctx,
          project_type: "node",
          organization_id: form.organization_id,
        )

        api_client = ShopifyCLI::Tasks::CreateApiClient.call(
          @ctx,
          org_id: form.organization_id,
          title: form.title,
          type: form.type,
        )

        ShopifyCLI::Resources::EnvFile.new(
          api_key: api_client["apiKey"],
          secret: api_client["apiSecretKeys"].first["secret"],
          shop: form.shop_domain,
          scopes: "write_products,write_customers,write_draft_orders",
        ).write(@ctx)

        partners_url = ShopifyCLI::PartnersAPI.partners_url_for(form.organization_id, api_client["id"])

        @ctx.puts(@ctx.message("apps.create.info.created", form.title, partners_url))
        @ctx.puts(@ctx.message("apps.create.info.serve", form.name, ShopifyCLI::TOOL_NAME, "node"))
        unless ShopifyCLI::Shopifolk.acting_as_shopify_organization?
          @ctx.puts(@ctx.message("apps.create.info.install", partners_url, form.title))
        end
      end

      def self.help
        ShopifyCLI::Context.message("node.create.help", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
      end

      private

      def check_node
        cmd_path = @ctx.which("node")
        @ctx.abort(@ctx.message("node.create.error.node_required")) if cmd_path.nil?

        version, stat = @ctx.capture2e("node", "-v")
        @ctx.abort(@ctx.message("node.create.error.node_version_failure")) unless stat.success?

        @ctx.done(@ctx.message("node.create.node_version", version))
      end

      def check_npm
        cmd_path = @ctx.which("npm")
        @ctx.abort(@ctx.message("node.create.error.npm_required")) if cmd_path.nil?

        version, stat = @ctx.capture2e("npm", "-v")
        @ctx.abort(@ctx.message("node.create.error.npm_version_failure")) unless stat.success?

        @ctx.done(@ctx.message("node.create.npm_version", version))
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

      def build(name)
        ShopifyCLI::Git.clone("https://github.com/Shopify/shopify-app-node.git", name)

        @ctx.root = File.join(@ctx.root, name)

        set_npm_config
        ShopifyCLI::JsDeps.install(@ctx, !options.flags[:verbose].nil?)

        begin
          @ctx.rm_r(".git")
          @ctx.rm_r(".github")
          @ctx.rm(File.join("server", "handlers", "client.js"))
          @ctx.rename(
            File.join("server", "handlers", "client.cli.js"),
            File.join("server", "handlers", "client.js")
          )
        rescue Errno::ENOENT => e
          @ctx.debug(e)
        end
      end
    end
  end
end
