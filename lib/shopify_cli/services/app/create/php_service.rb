require "semantic/semantic"

module ShopifyCLI
  module Services
    module App
      module Create
        class PHPService < BaseService
          attr_reader :name, :organization_id, :store_domain, :type, :verbose, :context

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
            form = PHP::Forms::Create.ask(context, [], {
              name: name,
              organization_id: organization_id,
              shop_domain: store_domain,
              type: type,
              verbose: verbose,
            })
            raise ShopifyCLI::AbortSilent if form.nil?

            check_php
            check_composer
            check_npm
            app_id = build(form)

            ShopifyCLI::Project.write(
              context,
              project_type: "php",
              organization_id: form.organization_id,
            )

            partners_url = ShopifyCLI::PartnersAPI.partners_url_for(form.organization_id, app_id)

            context.puts(context.message("apps.create.info.created", form.name, partners_url))
            context.puts(context.message("apps.create.info.serve", form.name, ShopifyCLI::TOOL_NAME))
            unless ShopifyCLI::Shopifolk.acting_as_shopify_organization?
              context.puts(context.message("apps.create.info.install", partners_url, form.name))
            end
          end

          private

          def check_php
            cmd_path = context.which("php")
            context.abort(context.message("core.app.create.php.error.php_required")) if cmd_path.nil?

            version, stat = context.capture2e("php", "-r", "echo phpversion();")
            context.abort(context.message("core.app.create.php.error.php_version_failure")) unless stat.success?

            if ::Semantic::Version.new(version) < ::Semantic::Version.new("7.3.0")
              context.abort(context.message("core.app.create.php.error.php_version_too_low", "7.3"))
            end

            context.done(context.message("core.app.create.php.php_version", version))
          end

          def check_composer
            cmd_path = context.which("composer")
            context.abort(context.message("core.app.create.php.error.composer_required")) if cmd_path.nil?
          end

          def check_npm
            version = ShopifyCLI::Environment.npm_version(context: context)
            context.done(context.message("core.app.create.php.npm_version", version))
          end

          def build(form)
            ShopifyCLI::Git.clone("https://github.com/Shopify/shopify-app-template-php.git#cli_two", form.name)

            context.root = File.join(context.root, form.name)
            context.chdir(context.root)

            api_client = ShopifyCLI::Tasks::CreateApiClient.call(
              context,
              org_id: form.organization_id,
              title: form.name,
              type: form.type,
            )

            # Override the example settings with our own
            context.cp(".env.example", ".env")

            env_file = ShopifyCLI::Resources::EnvFile.read
            env_file.api_key = api_client["apiKey"]
            env_file.secret = api_client["apiSecretKeys"].first["secret"]
            env_file.shop = form.shop_domain
            env_file.host = "localhost"
            env_file.scopes = "write_products,write_draft_orders,write_customers"
            env_file.extra["DB_DATABASE"] = File.join(context.root, env_file.extra["DB_DATABASE"])
            env_file.write(context)

            ShopifyCLI::PHPDeps.install(context, verbose)

            set_npm_config
            ShopifyCLI::JsDeps.install(context, verbose)

            title = context.message("core.app.create.php.app_setting_up")
            success = context.message("core.app.create.php.app_set_up")
            failure = context.message("core.app.create.php.error.app_setup")
            CLI::UI::Frame.open(title, success_text: success, failure_text: failure) do
              FileUtils.touch(env_file.extra["DB_DATABASE"])
              context.system("php", "artisan", "key:generate")
              context.system("php", "artisan", "migrate")
            end

            begin
              context.rm_r(".git")
              context.rm_r(".github")
            rescue Errno::ENOENT => e
              context.debug(e)
            end

            api_client["id"]
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
        end
      end
    end
  end
end
