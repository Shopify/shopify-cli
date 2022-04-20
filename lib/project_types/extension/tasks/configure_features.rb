module Extension
  module Tasks
    class ConfigureFeatures
      include ShopifyCLI::MethodObject

      class Error < RuntimeError; end
      class UnknownSurfaceArea < Error; end
      class UnspecifiedSurfaceArea < Error; end

      def call(specification_attribute_sets)
        specification_attribute_sets.each do |attributes|
          argo_configuration = extract_argo_configuration(attributes)
          next if argo_configuration.nil?
          surface_area = extract_surface_area(argo_configuration)
          if known_surface_area?(surface_area)
            surface_area_configuration = fetch_surface_area_configuration(surface_area)
            argo_configuration.merge!(surface_area_configuration)
          else
            clear_argo_configuration(attributes)
          end
        end
      end

      private

      def known_surface_area?(surface_area)
        surface_area_configurations.keys.include?(surface_area.to_sym)
      end

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

      def clear_argo_configuration(attributes)
        attributes[:name] = "#{attributes[:name]} (Warning: surface area not configured properly)"
        attributes[:features][:argo] = nil
      end

      def surface_area_configurations
        {
          admin: {
            git_template: "https://github.com/Shopify/admin-ui-extensions-template",
            renderer_package_name: "@shopify/admin-ui-extensions",
            required_fields: [:shop, :api_key],
            cli_package_name: "@shopify/admin-ui-extensions-run",
          },
          checkout: {
            git_template: "https://github.com/Shopify/checkout-ui-extensions-template",
            renderer_package_name: "@shopify/checkout-ui-extensions",
            required_fields: [:shop],
            cli_package_name: "@shopify/checkout-ui-extensions-run",
          },
          point_of_sale: {
            git_template: "",
            renderer_package_name: "@shopify/retail-ui-extensions",
          },
        }
      end
    end
  end
end
