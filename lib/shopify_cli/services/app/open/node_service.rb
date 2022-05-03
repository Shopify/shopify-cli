module ShopifyCLI
  module Services
    module App
      module Open
        class NodeService < OpenService
          def project_url
            "#{project.env.host}/api/auth?shop=#{project.env.shop}"
          end
        end
      end
    end
  end
end
