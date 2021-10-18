module ShopifyCLI
  module Services
    module App
      class OpenService < BaseService
        attr_reader :project, :context

        def initialize(project:, context:)
          @project = project
          @context = context
          super()
        end

        def call
          context.open_url!("#{project.env.host}/login?shop=#{project.env.shop}")
        end
      end
    end
  end
end
