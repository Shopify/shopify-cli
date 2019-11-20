require 'shopify_cli'

module ShopifyCli
  module Commands
    class Serve
      class ServeRails < ShopifyCli::Commands::Serve
        def call(*)
          setup
          Helpers::Gem.gem_home(@ctx)
          CLI::UI::Frame.open('Running server...') do
            @ctx.system(
              'bin/rails server',
              env: {
                PORT: ShopifyCli::Tasks::Tunnel::PORT,
              }
            )
          end
        end
      end
    end
  end
end
