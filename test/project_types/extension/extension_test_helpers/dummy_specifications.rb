# typed: ignore
module Extension
  module ExtensionTestHelpers
    module DummySpecifications
      def self.build(custom_handler_root: nil, custom_handler_namespace: nil, **specification_attributes)
        Models::Specifications.new do |s|
          s.custom_handler_root = custom_handler_root if custom_handler_root
          s.custom_handler_namespace = custom_handler_namespace if custom_handler_namespace
          s.fetch_specifications = -> { [build_attributes(**specification_attributes)] }
        end
      end

      def self.build_attributes(
        name: "Test Extension",
        identifier: name.downcase.gsub(" ", "_"),
        management_experience: "cli",
        surface: "admin"
      )
        {
          name: name,
          identifier: identifier,
          options: {
            management_experience: management_experience,
          },
          features: {
            argo: {
              surface: surface,
            },
          },
        }
      end
    end
  end
end
