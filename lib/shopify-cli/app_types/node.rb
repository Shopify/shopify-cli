require 'shopify_cli'

module ShopifyCli
  module AppTypes
    class Node < AppType
      class << self
        def env_file
          <<~KEYS
            SHOPIFY_API_KEY={api_key}
            SHOPIFY_API_SECRET_KEY={secret}
            HOST={host}
            SHOP={shop}
            SCOPES={scopes}
          KEYS
        end

        def description
          'node embedded app'
        end

        def serve_command(ctx)
          %W(
            HOST=#{ctx.project.env.host}
            PORT=#{ShopifyCli::Tasks::Tunnel::PORT}
            npm run dev
          ).join(' ')
        end

        def generate
          {
            page: 'npm run-script generate-page --silent',
            billing_recurring: 'npm run-script generate-recurring-billing --silent',
            billing_one_time: 'npm run-script generate-one-time-billing --silent',
            webhook: 'npm run-script generate-webhook --silent',
          }
        end

        def open(ctx)
          ctx.system('open', "#{ctx.project.env.host}/auth?shop=#{ctx.project.env.shop}")
        end
      end

      def build(name)
        ShopifyCli::Tasks::Clone.call('https://github.com/Shopify/shopify-app-node.git', name)
        ShopifyCli::Finalize.request_cd(name)
        ShopifyCli::Tasks::JsDeps.call(ctx.root)

        env_file = Helpers::EnvFile.new(
          app_type: self,
          api_key: ctx.app_metadata[:api_key],
          secret: ctx.app_metadata[:secret],
          host: ctx.app_metadata[:host],
          shop: ctx.app_metadata[:shop],
          scopes: 'write_products,write_customers,write_draft_orders',
        )
        env_file.write(ctx, '.env')

        begin
          ctx.rm_r(File.join(ctx.root, '.git'))
          ctx.rm_r(File.join(ctx.root, '.github'))
          ctx.rm(File.join(ctx.root, 'server', 'handlers', 'client.js'))
          ctx.rename(
            File.join(ctx.root, 'server', 'handlers', 'client.cli.js'),
            File.join(ctx.root, 'server', 'handlers', 'client.js')
          )
        rescue Errno::ENOENT => e
          ctx.debug(e)
        end

        puts CLI::UI.fmt(post_clone)
      end

      def check_dependencies
        deps = ['node -v', 'npm -v']
        deps.each do |dep|
          dep_name = dep.split.first
          dep_link = dep_name == 'node' ? 'https://nodejs.org/en/download.' : 'https://www.npmjs.com/get-npm'
          version, stat = ctx.capture2e(dep)
          ctx.puts("{{green:✔︎}} #{dep_name} #{version}")
          next if stat.success?
          raise(ShopifyCli::Abort,
            "#{dep_name} is required to create an app project. Download at #{dep_link}")
        end
      end
    end
  end
end
