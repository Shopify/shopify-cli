module ShopifyCLI
  module Services
    module App
      module Serve
        class RailsService < BaseService
          attr_accessor :host, :port, :context

          def initialize(host:, port:, context:)
            @host = host
            @port = port
            @context = context
            super()
          end

          def call
            project = ShopifyCLI::Project.current
            url = host || ShopifyCLI::Tunnel.start(context)
            raise ShopifyCLI::Abort,
              context.message("core.app.serve.error.host_must_be_https") if url.match(/^https/i).nil?
            project.env.update(context, :host, url)
            ShopifyCLI::Tasks::UpdateDashboardURLS.call(
              context,
              url: url,
              callback_url: "/auth/shopify/callback",
            )

            if project.env.shop
              project_url = "#{project.env.host}/login?shop=#{project.env.shop}"
              context.puts("\n" + context.message("core.app.serve.open_info", project_url) + "\n")
            end

            CLI::UI::Frame.open(context.message("core.app.serve.running_server")) do
              env = ShopifyCLI::Project.current.env.to_h
              env.delete("HOST")
              env["PORT"] = port
              env["GEM_PATH"] = Gem.gem_path(context)
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
