module ShopifyCLI
  module Services
    module App
      module Serve
        class NodeService < ServeService
          def call
            generate_url

            CLI::UI::Frame.open(context.message("core.app.serve.running_server")) do
              env = project.env.to_h
              env["PORT"] = port.to_s
              context.system("npm run dev", env: env)
            end
          end
        end
      end
    end
  end
end
