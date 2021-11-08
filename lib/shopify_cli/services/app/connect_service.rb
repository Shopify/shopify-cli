module ShopifyCLI
  module Services
    module App
      class ConnectService < BaseService
        attr_reader :app_type, :project, :context

        def initialize(app_type:, project:, context:)
          @app_type = app_type
          @project = project
          @context = context
          super()
        end

        def call
          unless project&.env.nil?
            context.puts(context.message("core.app.connect.production_warning"))
          end

          app = ShopifyCLI::Connect.new(context).default_connect(app_type.to_s)
          context.done(context.message("core.app.connect.connected", app))
        end
      end
    end
  end
end
