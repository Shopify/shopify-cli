module Extension
  module Tasks
    class ConfigureFeatures
      include ShopifyCli::MethodObject

      class Error < RuntimeError; end
      class UnknownSurfaceArea < Error; end
      class UnspecifiedSurfaceArea < Error; end

      def call(specification_attribute_sets)
        specification_attribute_sets.each do |attributes|
          argo_configuration = extract_argo_configuration(attributes)
          next if argo_configuration.nil?
          surface_area = extract_surface_area(argo_configuration)
          surface_area_configuration = fetch_surface_area_configuration(surface_area)
          argo_configuration.merge!(surface_area_configuration)
        end
      end

      private

      def extract_argo_configuration(attributes)
        attributes.dig(:features, :argo)
      end

      def extract_surface_area(argo_configuration)
        argo_configuration.fetch(:surface) do
          raise UnspecifiedSurfaceArea, "Argo configuration does not specify surface area"
        end
      end

      def fetch_surface_area_configuration(surface_area)
        surface_area_configurations.fetch(surface_area.to_sym) do
          raise UnknownSurfaceArea, "Unknown surface area: #{surface_area}"
        end
      end

      def surface_area_configurations
        {
          admin: {
            git_template: "https://github.com/Shopify/argo-admin-template.git",
            renderer_package_name: "@shopify/argo-admin",
            required_fields: [:shop, :api_key],
            required_shop_beta_flags: [:argo_admin_beta],
          },
          checkout: {
            git_template: "https://github.com/Shopify/argo-checkout-template.git",
            renderer_package_name: "@shopify/argo-checkout",
          },
        }
      end
    end
  end
end
