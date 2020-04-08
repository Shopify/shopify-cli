# frozen_string_literal: true
module Node
  module Commands
    class Create < ShopifyCli::SubCommand
      NPM_REGISTRY_NOTICE = <<~MSG
        You are not using the public npm registry for Shopify packages. This can cause issues with installing @shopify packages.
        Please run `npm config set @shopify:registry https://registry.yarnpkg.com` and try this command again,
        or preface the command with `DISABLE_NPM_REGISTRY_CHECK=1`.
      MSG
      NODE_REQUIRED_NOTICE = "node is required to create an app project. Download at https://nodejs.org/en/download."
      NPM_REQUIRED_NOTICE = "node is required to create an app project. Download at https://www.npmjs.com/get-npm."

      options do |parser, flags|
        parser.on('--title=TITLE') { |t| flags[:title] = t }
        parser.on('--organization_id=ID') { |url| flags[:organization_id] = url }
        parser.on('--shop_domain=MYSHOPIFYDOMAIN') { |url| flags[:shop_domain] = url }
        parser.on('--type=APPTYPE') { |url| flags[:type] = url }
      end

      def call(args, _name)
        form = Forms::Create.ask(@ctx, args, options.flags)
        return @ctx.puts(self.class.help) if form.nil?

        check_node
        check_npm
        build(form.name)

        ShopifyCli::Project.write(@ctx, 'node')

        api_client = ShopifyCli::Tasks::CreateApiClient.call(
          @ctx,
          org_id: form.organization_id,
          title: form.title,
          type: form.type,
          app_url: 'https://shopify.github.io/shopify-app-cli/getting-started',
        )

        ShopifyCli::Helpers::EnvFile.new(
          api_key: api_client["apiKey"],
          secret: api_client["apiSecretKeys"].first["secret"],
          shop: form.shop_domain,
          scopes: 'write_products,write_customers,write_draft_orders',
        ).write(@ctx)

        partners_url = "https://partners.shopify.com/#{form.organization_id}/apps/#{api_client['id']}"

        @ctx.puts("{{v}} {{green:#{form.title}}} was created in your Partner" \
                  " Dashboard " \
                  "{{underline:#{partners_url}}}")
        @ctx.puts("{{*}} Run {{command:#{ShopifyCli::TOOL_NAME} serve}} to start a local server")
        @ctx.puts("{{*}} Then, visit {{underline:#{partners_url}/test}} to install" \
                  " {{green:#{form.title}}} on your Dev Store")
      end

      def self.help
        <<~HELP
        {{command:#{ShopifyCli::TOOL_NAME} create node}}: Creates an embedded nodejs app.
          Usage: {{command:#{ShopifyCli::TOOL_NAME} create node}}
          Options:
            {{command:--title=TITLE}} App project title. Any string.
            {{command:--app_url=APPURL}} App project URL. Must be valid URL.
            {{command:--organization_id=ID}} App project Org ID. Must be existing org ID.
            {{command:--shop_domain=MYSHOPIFYDOMAIN }} Test store URL. Must be existing test store.
        HELP
      end

      private

      def check_node
        version, stat = @ctx.capture2e('node', '-v')
        @ctx.done("node #{version}")
        @ctx.abort(NODE_REQUIRED_NOTICE) unless stat.success?
      end

      def check_npm
        version, stat = @ctx.capture2e('npm', '-v')
        @ctx.done("npm #{version}")
        @ctx.abort(NPM_REQUIRED_NOTICE) unless stat.success?
        return unless @ctx.getenv('DISABLE_NPM_REGISTRY_CHECK').nil?
        registry, _ = @ctx.capture2('npm config get @shopify:registry')
        return if registry.include?('https://registry.yarnpkg.com')
        @ctx.abort(NPM_REGISTRY_NOTICE)
      end

      def build(name)
        ShopifyCli::Git.clone('https://github.com/Shopify/shopify-app-node.git', name)
        ShopifyCli::Core::Finalize.request_cd(name)

        @ctx.root = File.join(@ctx.root, name)

        JsDeps.install(@ctx)

        begin
          @ctx.rm_r(File.join(@ctx.root, '.git'))
          @ctx.rm_r(File.join(@ctx.root, '.github'))
          @ctx.rm(File.join(@ctx.root, 'server', 'handlers', 'client.js'))
          @ctx.rename(
            File.join(@ctx.root, 'server', 'handlers', 'client.cli.js'),
            File.join(@ctx.root, 'server', 'handlers', 'client.js')
          )
        rescue Errno::ENOENT => e
          @ctx.debug(e)
        end
      end
    end
  end
end
