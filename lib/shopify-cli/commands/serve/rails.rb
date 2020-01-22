require 'shopify_cli'

module ShopifyCli
  module Commands
    class Serve
      class ServeRails < ShopifyCli::Commands::Serve
        def call(*)
          setup
          Helpers::Gem.gem_home(@ctx)
          CLI::UI::Frame.open('Running server...') do
            env = Project.current.env.to_h
            env.delete('HOST')
            env['PORT'] = ShopifyCli::Tasks::Tunnel::PORT.to_s
            @ctx.system('bin/rails server', env: env)
          end
        end
      end
    end
  end
end
