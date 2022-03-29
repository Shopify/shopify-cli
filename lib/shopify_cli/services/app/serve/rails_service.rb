module ShopifyCLI
  module Services
    module App
      module Serve
        class RailsService < ServeService
          def call
            generate_url

            CLI::UI::Frame.open(context.message("core.app.serve.running_server")) do
              env = ShopifyCLI::Project.current.env.to_h
              env.delete("HOST")
              env["PORT"] = port.to_s
              env["GEM_PATH"] = Rails::Gem.gem_path(context)
              if context.windows?
                context.system("ruby bin\\rails server", env: env)
              else
                context.system("bin/rails server", env: env)
              end
            end
          end
        end
      end
    end
  end
end
