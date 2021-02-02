module Extension
  module Models
    class Specifications
      include SmartProperties

      property! :custom_handler_root,
        accepts: ->(d) { File.directory?(d) },
        default: -> { File.expand_path('lib/project_types/extension/models/specification_handlers', ShopifyCli::ROOT) }

      property! :custom_handler_namespace,
        accepts: ->(m) { m.respond_to?(:const_get) },
        default: -> { ::Extension::Models::SpecificationHandlers }

      property! :fetch_specifications,
        accepts: ->(p) { p.respond_to?(:to_proc) }

      def initialize(*)
        super
        @handlers = fetch_specifications_and_build_handlers
      end

      def [](identifier)
        handlers[identifier]
      end

      def valid?(identifier)
        handlers.key?(identifier)
      end

      def each(&block)
        handlers.values.each(&block)
      end

      protected

      attr_reader :handlers

      private

      def fetch_specifications_and_build_handlers
        ShopifyCli::Result
          .wrap(&fetch_specifications)
          .call
          .then(&method(:require_handler_implementations))
          .then(&method(:instantiate_specification_handlers))
          .unwrap { |err| raise err }
      end

      def require_handler_implementations(specifications)
        specifications.each { |s| require(File.join(custom_handler_root, "#{s.identifier}.rb")) }
      end

      def instantiate_specification_handlers(specifications)
        specifications.each_with_object({}) do |specification, handlers|
          handler = custom_handler_namespace.const_get(specification.handler_class_name).new
          handlers[handler.identifier] = handler
        end
      end
    end
  end
end
