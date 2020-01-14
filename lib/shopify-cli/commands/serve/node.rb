require 'shopify_cli'

module ShopifyCli
  module Commands
    class Serve
      class ServeNode < ShopifyCli::Commands::Serve
        def call(*)
          setup
          CLI::UI::Frame.open('Running server...') do
            @ctx.system(
              'npm run dev',
              env: {
                'HOST' => Project.current.env.host,
                'PORT' => ShopifyCli::Tasks::Tunnel::PORT.to_s,
              }
            )
          end
        end
      end
    end
  end
end
