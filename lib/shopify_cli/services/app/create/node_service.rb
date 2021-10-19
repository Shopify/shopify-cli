require "semantic/semantic"

module ShopifyCLI
  module Services
    module App
      module Create
        class NodeService < BaseService
          attr_reader :context, :name, :organization_id, :shop_domain, :type, :verbose

          def initialize(name:, organization_id:, shop_domain:, type:, verbose:, context:)
            @name = name
            @organization_id = organization_id
            @shop_domain = shop_domain
            @type = type
            @verbose = verbose
            @context = context
            super()
          end

          def call
            form = Node::Forms::Create.ask(context, [], {
              name: name,
              organization_id: organization_id,
              shop_domain: shop_domain,
              type: type,
              verbose: verbose,
            })

            check_node
            check_npm
            build(form.name)

            ShopifyCLI::Project.write(
              context,
              project_type: "node",
              organization_id: form.organization_id,
            )

            api_client = ShopifyCLI::Tasks::CreateApiClient.call(
              context,
              org_id: form.organization_id,
              title: form.title,
              type: form.type,
            )

            ShopifyCLI::Resources::EnvFile.new(
              api_key: api_client["apiKey"],
              secret: api_client["apiSecretKeys"].first["secret"],
              shop: form.shop_domain,
              scopes: "write_products,write_customers,write_draft_orders",
            ).write(context)

            partners_url = ShopifyCLI::PartnersAPI.partners_url_for(form.organization_id, api_client["id"])

            context.puts(context.message("apps.create.info.created", form.title, partners_url))
            context.puts(context.message("apps.create.info.serve", form.name, ShopifyCLI::TOOL_NAME, "node"))
            unless ShopifyCLI::Shopifolk.acting_as_shopify_organization?
              context.puts(context.message("apps.create.info.install", partners_url, form.title))
            end
          end

          private

          def check_node
            cmd_path = context.which("node")
            context.abort(context.message("node.create.error.node_required")) if cmd_path.nil?

            version, stat = context.capture2e("node", "-v")
            context.abort(context.message("node.create.error.node_version_failure")) unless stat.success?

            context.done(context.message("node.create.node_version", version))
          end

          def check_npm
            cmd_path = context.which("npm")
            context.abort(context.message("node.create.error.npm_required")) if cmd_path.nil?

            version, stat = context.capture2e("npm", "-v")
            context.abort(context.message("node.create.error.npm_version_failure")) unless stat.success?

            context.done(context.message("node.create.npm_version", version))
          end

          def set_npm_config
            # check available npmrc (either user or system) for production registry
            registry, _ = context.capture2("npm config get @shopify:registry")
            return if registry.include?("https://registry.yarnpkg.com")

            # available npmrc doesn't have production registry =>
            # set a project-based .npmrc
            context.system(
              "npm",
              "--userconfig",
              "./.npmrc",
              "config",
              "set",
              "@shopify:registry",
              "https://registry.yarnpkg.com",
              chdir: context.root
            )
          end

          def build(name)
            ShopifyCLI::Git.clone("https://github.com/Shopify/shopify-app-node.git", name)

            context.root = File.join(context.root, name)

            set_npm_config
            ShopifyCLI::JsDeps.install(context, verbose)

            begin
              context.rm_r(".git")
              context.rm_r(".github")
              context.rm(File.join("server", "handlers", "client.js"))
              context.rename(
                File.join("server", "handlers", "client.cli.js"),
                File.join("server", "handlers", "client.js")
              )
            rescue Errno::ENOENT => e
              context.debug(e)
            end
          end
        end
      end
    end
  end
end
