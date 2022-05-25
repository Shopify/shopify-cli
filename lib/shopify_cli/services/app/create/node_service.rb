require "semantic/semantic"

module ShopifyCLI
  module Services
    module App
      module Create
        class NodeService < BaseService
          attr_reader :context, :name, :organization_id, :store_domain, :type, :verbose

          def initialize(name:, organization_id:, store_domain:, type:, verbose:, context:)
            @name = name
            @organization_id = organization_id
            @store_domain = store_domain
            @type = type
            @verbose = verbose
            @context = context
            super()
          end

          def call
            form = form_data({
              name: name,
              organization_id: organization_id,
              shop_domain: store_domain,
              type: type,
              verbose: verbose,
            })

            raise ShopifyCLI::AbortSilent if form.nil?

            check_node
            check_npm
            build(form.name)

            ShopifyCLI::Project.write(
              context,
              project_type: "node",
              organization_id: form.organization_id,
              is_new_template: true
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
              Struct.new(:name, :organization_id, :type, :shop_domain, keyword_init: true).new(
                name: form_options[:name],
                organization_id: form_options[:organization_id] || "123",
                shop_domain: form_options[:shop_domain] || "test.shopify.io",
                type: form_options[:type] || "public",
              )
            else
              Node::Forms::Create.ask(context, [], form_options)
            end
          end

          def check_node
            version = ShopifyCLI::Environment.node_version(context: context)
            context.done(context.message("core.app.create.node.node_version", version))
          end

          def check_npm
            version = ShopifyCLI::Environment.npm_version(context: context)
            context.done(context.message("core.app.create.node.npm_version", version))
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
            app_folder = File.join(context.root, name)

            ShopifyCLI::Git.clone("https://github.com/Shopify/starter-node-app.git", name)

            context.chdir(app_folder)
            ShopifyCLI::Git.update_submodules(context)

            set_npm_config

            # Clean up the repo
            context.rename("package.json", "package.json.cli3beta")
            context.rename("package.json.cli2", "package.json")

            root = context.root
            Dir.glob("**/package.json").each do |package_json|
              next if /node_modules/ =~ package_json

              # set dir and install deps
              context.chdir(File.join(root, File.dirname(package_json)))
              ShopifyCLI::JsDeps.install(context, verbose)
            end

            context.chdir(app_folder)

            begin
              context.rm_r(".git")
              context.rm_r(".github")
              context.rm_r(".gitmodules")
            rescue Errno::ENOENT => e
              context.debug(e)
            end
          ensure
            context.chdir(app_folder)
          end
        end
      end
    end
  end
end
