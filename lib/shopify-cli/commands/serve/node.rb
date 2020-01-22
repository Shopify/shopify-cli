require 'shopify_cli'

module ShopifyCli
  module Commands
    class Serve
      class ServeNode < ShopifyCli::Commands::Serve
        def call(*)
          setup
          CLI::UI::Frame.open('Running server...') do
            env = Project.current.env.to_h
            env['PORT'] = ShopifyCli::Tasks::Tunnel::PORT.to_s
            @ctx.system('npm run dev', env: env)
          end
        end
      end
    end
  end
end
