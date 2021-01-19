module Extension
  module Specifications
    class CreateHandler
      include MethodObject
      
      property! :namespace, accepts: Module, default: Handlers
      property! :default_handler, accepts: Class, default: Handlers::Default

      def call(specifications)
        transform(specifications) do |specification|
          handler.new(specification)
        end
      end

      private

      def handler
        return custom_handler if custom_handler_defined?
        default_handler
      end

      def custom_handler_defined?
        false
      end

      def custom_handler
        Result
          .new { require_file(custom_handler_basename) }
          .and_then { resolve_constant(custom_handler_class_name) }
          .ok_value_or_else { |e| raise e }
      end

      def custom_handler_class_name

      end

      def custom_handler_path

      end

      def require_file(basename)

      end

      def resolve_constant(constant_name)
        namespace.const_get(constant_name)
      end
    end
  end
end
