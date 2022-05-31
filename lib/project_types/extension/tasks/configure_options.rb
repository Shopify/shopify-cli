module Extension
  module Tasks
    class ConfigureOptions
      include ShopifyCLI::MethodObject

      def call(specification_attribute_sets)
        specification_attribute_sets.each do |attributes|
          attributes[:options] ||= {}
          configure_skip_build(attributes)
        end
      end

      private

      def configure_skip_build(attributes)
        attributes[:options].merge!(skip_build: attributes[:identifier] == "theme_app_extension" ||
         attributes[:identifier] == "web_pixel_extension")
      end
    end
  end
end
