module ShopifyCLI
  module Services
    module App
      module Serve
        class ServeService < BaseService
          attr_accessor :host, :port, :no_update, :context

          def initialize(host:, port:, no_update:, context:)
            @host = host
            @port = port
            @no_update = no_update
            @context = context
            super()
          end

          def call
            raise NotImplementedError
          end

          private

          def generate_url
            create_tunnel
            update_url unless no_update
            show_app_url
          end

          def create_tunnel
            url = host || ShopifyCLI::Tunnel.start(context, port: port)
            raise ShopifyCLI::Abort,
              context.message("core.app.serve.error.host_must_be_https") if url.match(/^https/i).nil?
            project.env.update(context, :host, url)
          end

          def update_url
            ShopifyCLI::Tasks::UpdateDashboardURLS.call(
              context,
              url: project.env.host,
              callback_urls: %w(/auth/shopify/callback /auth/callback),
            )
          end

          def show_app_url
            return unless project.env.shop

            project_url = "#{project.env.host}/login?shop=#{project.env.shop}"
            context.puts("\n" + context.message("core.app.serve.open_info", project_url) + "\n")
          end

          def project
            @project ||= ShopifyCLI::Project.current
          end
        end
      end
    end
  end
end
