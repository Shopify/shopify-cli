require_relative "type_translator"
require_relative "type"

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class SingularType < Type
        ASSIGNMENT_TRANSLATIONS = {
          "Str" => "Str.from(%{name})",
        }

        private_constant :ASSIGNMENT_TRANSLATIONS

        def initialize(graphql_type, name, ts_type)
          super(graphql_type, name, ts_type)
        end

        private

        # translate shopify_runtime_types with conversion wrapper functions for constructor assignments
        def translate_assignment_rhs
          ASSIGNMENT_TRANSLATIONS.key?(@ts_type) ? format(ASSIGNMENT_TRANSLATIONS[@ts_type], name: @name) : @name
        end

        # translate shopify_runtime_types to TS types for constructor parameter arguments
        def translate_constructor_type
          Type::CTOR_TYPE_TRANSLATIONS[@ts_type] || @ts_type
        end
      end
    end
  end
end
