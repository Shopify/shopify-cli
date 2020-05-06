# frozen_string_literal: true
module Node
  module Commands
    class Create < ShopifyCli::SubCommand
      NODE_REQUIRED_NOTICE = "node is required to create an app project. Download at https://nodejs.org/en/download."
      NODE_VERSION_FAILURE_NOTICE = "Failed to get the current node version. Please make sure it is installed as per " \
        "the instructions at https://nodejs.org/en."
      NPM_REQUIRED_NOTICE = "npm is required to create an app project. Download at https://www.npmjs.com/get-npm."
      NPM_VERSION_FAILURE_NOTICE = "Failed to get the current npm version. Please make sure it is installed as per " \
        "the instructions at https://www.npmjs.com/get-npm."

      options do |parser, flags|
        # backwards compatibility allow 'title' for now
        parser.on('--title=TITLE') { |t| flags[:title] = t }
        parser.on('--name=NAME') { |t| flags[:title] = t }
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

        ShopifyCli::Project.write(
          @ctx,
          app_type: 'node',
          partner_id: form.organization_id.to_i,
        )

        api_client = ShopifyCli::Tasks::CreateApiClient.call(
          @ctx,
          org_id: form.organization_id,
          title: form.title,
          type: form.type,
          app_url: 'https://shopify.github.io/shopify-app-cli/getting-started',
        )

        ShopifyCli::Resources::EnvFile.new(
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
            {{command:--name=NAME}} App name. Any string.
            {{command:--app_url=APPURL}} App URL. Must be valid URL.
            {{command:--organization_id=ID}} App Org ID. Must be existing org ID.
            {{command:--shop_domain=MYSHOPIFYDOMAIN }} Test store URL. Must be existing test store.
        HELP
      end

      private

      def check_node
        _, stat = @ctx.capture2e('which', 'node')
        @ctx.abort(NODE_REQUIRED_NOTICE) unless stat.success?

        version, stat = @ctx.capture2e('node', '-v')
        @ctx.abort(NODE_VERSION_FAILURE_NOTICE) unless stat.success?

        @ctx.done("node #{version}")
      end

      def check_npm
        _, stat = @ctx.capture2e('which', 'npm')
        @ctx.abort(NPM_REQUIRED_NOTICE) unless stat.success?

        version, stat = @ctx.capture2e('npm', '-v')
        @ctx.abort(NPM_VERSION_FAILURE_NOTICE) unless stat.success?

        @ctx.done("npm #{version}")
      end

      def set_npm_config
        # check available npmrc (either user or system) for production registry
        registry, _ = @ctx.capture2('npm config get @shopify:registry')
        return if registry.include?('https://registry.yarnpkg.com')

        # available npmrc doesn't have production registry =>
        # set a project-based .npmrc
        @ctx.system(
          'npm',
          '--userconfig',
          './.npmrc',
          'config',
          'set',
          '@shopify:registry',
          'https://registry.yarnpkg.com',
          chdir: @ctx.root
        )
      end

      def build(name)
        ShopifyCli::Git.clone('https://github.com/Shopify/shopify-app-node.git', name)
        ShopifyCli::Core::Finalize.request_cd(name)

        @ctx.root = File.join(@ctx.root, name)

        set_npm_config
        JsDeps.install(@ctx)

        begin
          @ctx.rm_r('.git')
          @ctx.rm_r('.github')
          @ctx.rm(File.join('server', 'handlers', 'client.js'))
          @ctx.rename(
            File.join('server', 'handlers', 'client.cli.js'),
            File.join('server', 'handlers', 'client.js')
          )
        rescue Errno::ENOENT => e
          @ctx.debug(e)
        end
      end
    end
  end
end
