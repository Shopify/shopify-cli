module Extension
  module Models
    class Specifications
      include SmartProperties

      property! :custom_handler_root,
        accepts: ->(d) { File.directory?(d) },
        default: -> { File.expand_path("lib/project_types/extension/models/specification_handlers", ShopifyCLI::ROOT) }

      property! :custom_handler_namespace,
        accepts: ->(m) { m.respond_to?(:const_get) },
        default: -> { ::Extension::Models::SpecificationHandlers }

      property! :fetch_specifications,
        accepts: ->(p) { p.respond_to?(:to_proc) }

      def [](identifier)
        handlers[identifier]
      end

      def valid?(identifier)
        handlers.key?(identifier)
      end

      def each(&block)
        handlers.values.each(&block)
      end

      def none?
        each.none?
      end

      protected

      def handlers
        @handlers ||= fetch_specifications_and_build_handlers
      end

      private

      def fetch_specifications_and_build_handlers
        ShopifyCLI::Result
          .call(&fetch_specifications)
          .map(&ShopifyCLI::TransformDataStructure.new(symbolize_keys: true, underscore_keys: true))
          .then(&method(:select_cli_extensions))
          .then(&Tasks::ConfigureFeatures)
          .then(&Tasks::ConfigureOptions)
          .then(&method(:ensure_legacy_compatibility))
          .then(&method(:build_specifications))
          .then(&method(:require_handler_implementations))
          .then(&method(:instantiate_specification_handlers))
          .unwrap { |err| raise err }
      end

      def require_handler_implementations(specifications)
        specifications.each do |s|
          implementation_file = File.join(custom_handler_root, "#{s.identifier}.rb")
          require(implementation_file) if File.file?(implementation_file)
        end
      end

      def instantiate_specification_handlers(specifications)
        specifications.each_with_object({}) do |specification, handlers|
          ShopifyCLI::ResolveConstant.call(specification.identifier, namespace: custom_handler_namespace)
            .rescue { |error| error.is_a?(NameError) ? SpecificationHandlers::Default : raise(error) }
            .then { |handler_class| handler_class.new(specification) }
            .unwrap { |error| raise error }
            .yield_self { |handler| handlers[handler.identifier] = handler }
        end
      end

      def ensure_legacy_compatibility(specification_attribute_sets)
        specification_attribute_sets.each do |attributes|
          next unless attributes.fetch(:identifier) == "subscription_management"
          attributes[:identifier] = "product_subscription"
          attributes[:graphql_identifier] = "SUBSCRIPTION_MANAGEMENT"
        end
      end

      def build_specifications(specification_attribute_sets)
        specification_attribute_sets.map { |attributes| Models::Specification.new(**attributes) }
      end

      def select_cli_extensions(specification_attribute_sets)
        specification_attribute_sets.select { |attributes| attributes.dig(:options, :management_experience) == "cli" }
      end
    end
  end
end
