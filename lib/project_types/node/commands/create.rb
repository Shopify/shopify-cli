# frozen_string_literal: true
module Node
  module Commands
    class Create < ShopifyCli::SubCommand
      options do |parser, flags|
        # backwards compatibility allow 'title' for now
        parser.on('--title=TITLE') { |t| flags[:title] = t }
        parser.on('--name=NAME') { |t| flags[:title] = t }
        parser.on('--organization_id=ID') { |url| flags[:organization_id] = url }
        parser.on('--shop_domain=MYSHOPIFYDOMAIN') { |url| flags[:shop_domain] = url }
        parser.on('--type=APPTYPE') { |url| flags[:type] = url }
        parser.on('--verbose') { flags[:verbose] = true }
      end

      def call(args, _name)
        form = Forms::Create.ask(@ctx, args, options.flags)
        return @ctx.puts(self.class.help) if form.nil?

        check_node
        check_npm
        build(form.name)

        ShopifyCli::Project.write(
          @ctx,
          project_type: 'node',
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
          scopes: 'write_products,write_customers,write_draft_orders',
        ).write(@ctx)

        partners_url = partners_url_for(form.organization_id, api_client['id'])

        @ctx.puts(@ctx.message('apps.create.info.created', form.title, partners_url))
        @ctx.puts(@ctx.message('apps.create.info.serve', form.name, ShopifyCli::TOOL_NAME))
        @ctx.puts(@ctx.message('apps.create.info.install', partners_url, form.title))
      end

      def self.help
        ShopifyCli::Context.message('node.create.help', ShopifyCli::TOOL_NAME, ShopifyCli::TOOL_NAME)
      end

      private

      def check_node
        cmd_path = @ctx.which('node')
        @ctx.abort(@ctx.message('node.create.error.node_required')) if cmd_path.nil?

        version, stat = @ctx.capture2e('node', '-v')
        @ctx.abort(@ctx.message('node.create.error.node_version_failure')) unless stat.success?

        @ctx.done(@ctx.message('node.create.node_version', version))
      end

      def check_npm
        cmd_path = @ctx.which('npm')
        @ctx.abort(@ctx.message('node.create.error.npm_required')) if cmd_path.nil?

        version, stat = @ctx.capture2e('npm', '-v')
        @ctx.abort(@ctx.message('node.create.error.npm_version_failure')) unless stat.success?

        @ctx.done(@ctx.message('node.create.npm_version', version))
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

        @ctx.root = File.join(@ctx.root, name)

        set_npm_config
        ShopifyCli::JsDeps.install(@ctx, !options.flags[:verbose].nil?)

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

      def partners_url_for(organization_id, api_client_id)
        if ShopifyCli::Shopifolk.acting_as_shopify_organization?
          organization_id = 'internal'
        end
        "#{partners_endpoint}/#{organization_id}/apps/#{api_client_id}"
      end

      def partners_endpoint
        domain = if @ctx.getenv(ShopifyCli::PartnersAPI::LOCAL_DEBUG)
          'partners.myshopify.io'
        else
          'partners.shopify.com'
        end
        "https://#{domain}"
      end
    end
  end
end
