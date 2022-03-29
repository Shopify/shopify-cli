module ShopifyCLI
  module Services
    module App
      module Serve
        class PHPService < ServeService
          def call
            generate_url

            CLI::UI::Frame.open(context.message("core.app.serve.running_server")) do
              if ShopifyCLI::ProcessSupervision.running?(:npm_watch)
                ShopifyCLI::ProcessSupervision.stop(:npm_watch)
              end
              ShopifyCLI::ProcessSupervision.start(:npm_watch, "npm run watch", force_spawn: true)

              env = project.env.to_h
              context.system("php", "artisan", "serve", "--port", port.to_s, env: env)
            end
          end
        end
      end
    end
  end
end
