require 'shopify_cli'

module ShopifyCli
  module AppTypes
    class Node < AppType
      class << self
        def description
          'node embedded app'
        end

        def serve_command(_ctx)
          %W(
            HOST=#{Project.current.env.host}
            PORT=#{ShopifyCli::Tasks::Tunnel::PORT}
            npm run dev
          ).join(' ')
        end

        def generate
          {
            empty_state: './node_modules/.bin/generate-node-app empty-state-page',
            two_column: './node_modules/.bin/generate-node-app two-column-page',
            annotated: './node_modules/.bin/generate-node-app settings-page',
            list: './node_modules/.bin/generate-node-app list-page',
            billing_recurring: './node_modules/.bin/generate-node-app recurring-billing',
            billing_one_time: './node_modules/.bin/generate-node-app one-time-billing',
            webhook: './node_modules/.bin/generate-node-app webhook',
          }
        end

        def page_types
          {
            'empty-state' => :empty_state,
            'list' => :list,
            'two-column' => :two_column,
            'annotated' => :annotated,
          }
        end

        def generate_command(selected_type)
          "#{generate[:webhook]} #{selected_type}"
        end

        def open_url
          "#{Project.current.env.host}/auth?shop=#{Project.current.env.shop}"
        end

        def webhook_location
          "pages/server.js"
        end

        def callback_url
          "/auth/callback"
        end
      end

      def build(name)
        ShopifyCli::Tasks::Clone.call('https://github.com/Shopify/shopify-app-node.git', name)
        ShopifyCli::Finalize.request_cd(name)
        ShopifyCli::Tasks::JsDeps.call(ctx)

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
      end

      def check_dependencies
        check_npm_node
        check_npm_registry
      end

      def check_npm_node
        deps = ['node -v', 'npm -v']
        deps.each do |dep|
          dep_name = dep.split.first
          dep_link = dep_name == 'node' ? 'https://nodejs.org/en/download.' : 'https://www.npmjs.com/get-npm'
          version, stat = ctx.capture2e(dep)
          ctx.puts("{{v}} #{dep_name} #{version}")
          next if stat.success?
          raise(ShopifyCli::Abort,
            "#{dep_name} is required to create an app project. Download at #{dep_link}")
        end
      end

      def check_npm_registry
        if ctx.getenv('DISABLE_NPM_REGISTRY_CHECK').nil?
          registry, _ = ctx.capture2('npm', 'config', 'get', '@shopify:registry')
          msg = <<~MSG
            You are not using the public npm registry for Shopify packages. This can cause issues with installing @shopify packages.
            Please run `npm config set @shopify:registry https://registry.yarnpkg.com` and try this command again,
            or preface the command with `DISABLE_NPM_REGISTRY_CHECK=1`.
          MSG
          raise(ShopifyCli::Abort, msg) unless registry.include?('https://registry.yarnpkg.com')
        end
      end
    end
  end
end
