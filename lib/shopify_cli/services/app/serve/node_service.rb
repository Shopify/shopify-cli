module ShopifyCLI
  module Services
    module App
      module Serve
        class NodeService < ServeService
          def call
            generate_url

            CLI::UI::Frame.open(context.message("core.app.serve.running_server")) do
              env = project.env.to_h

              # This is the updated node app repo, so we need to run FE and BE separately
              if new_repo?
                env["FRONTEND_PORT"] = port.to_s
                env["BACKEND_PORT"] = (port.to_i + 1).to_s

                Dir.chdir(File.join(context.root, "web", "frontend")) do
                  if ShopifyCLI::ProcessSupervision.running?(:frontend)
                    ShopifyCLI::ProcessSupervision.stop(:frontend)
                  end
                  ShopifyCLI::ProcessSupervision.start(:frontend, "npm run dev", force_spawn: true, env: env)
                end

                Dir.chdir(File.join(context.root, "web")) do
                  context.system("npm run dev", env: env)
                end
              else
                env["PORT"] = port.to_s
                context.system("npm run dev", env: env)
              end
            end
          end

          def project_url
            if new_repo?
              "#{project.env.host}/api/auth?shop=#{project.env.shop}"
            else
              "#{project.env.host}/login?shop=#{project.env.shop}"
            end
          end

          def callback_urls
            if new_repo?
              %w(/api/auth/callback)
            else
              %w(/auth/shopify/callback /auth/callback)
            end
          end

          private

          def new_repo?
            @is_new_repo ||= File.exist?(File.join(context.root, "shopify.app.toml"))
          end
        end
      end
    end
  end
end
