module ShopifyCLI
  module Services
    module App
      module Open
        class NodeService < OpenService
          def project_url
            if project.config["is_new_template"]
              "#{project.env.host}/api/auth?shop=#{project.env.shop}"
            else
              "#{project.env.host}/login?shop=#{project.env.shop}"
            end
          end
        end
      end
    end
  end
end
