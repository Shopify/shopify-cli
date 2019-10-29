module ShopifyCli
  module ScriptModule
    module Infrastructure
      class Type
        attr_reader :graphql_type
        attr_reader :ts_type
        attr_reader :name
        attr_reader :constructor_type
        attr_reader :assignment_rhs_type

        CTOR_TYPE_TRANSLATIONS = {
          "Str" => "String",
        }

        def initialize(graphql_type, name, ts_type)
          @graphql_type = graphql_type
          @name = name
          @ts_type = ts_type
          @constructor_type = translate_constructor_type
          @assignment_rhs_type = translate_assignment_rhs
        end

        def wrapper
          ""
        end

        private

        def singular_name
          raise NotImplementedError
        end

        def plural_name
          raise NotImplementedError
        end
      end
    end
  end
end
