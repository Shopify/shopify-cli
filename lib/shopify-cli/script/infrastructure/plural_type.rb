require_relative "type_translator"
require_relative "type"

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class PluralType < Type
        TYPESCRIPT_SLICE_WRAPPER_TEMPLATE =
          <<~HEREDOC
            @unmanaged
            export class %{plural_name} extends Slice<%{singular_name}> {
              static fromArray(arr: Array<%{singular_name}>): %{plural_name} {
                return <%{plural_name}>Slice.fromArray<%{singular_name}>(arr);
              }

              @inline
              static from(arr: Array<%{singular_name}>): %{plural_name} {
                return %{plural_name}.fromArray(arr);
              }
            }
          HEREDOC

        SLICE_ASSIGNMENT_WRAPPER_TEMPLATE = "Slice.from<%{singular_name}>(%{value_name})"
        SLICE_SLICEUTF8_TEMPLATE = "%{name}.map(x => Str.from(x))"

        private_constant :TYPESCRIPT_SLICE_WRAPPER_TEMPLATE,
          :SLICE_ASSIGNMENT_WRAPPER_TEMPLATE, :SLICE_SLICEUTF8_TEMPLATE

        def initialize(graphql_type, name, ts_type)
          super(graphql_type, name, ts_type)
        end

        def wrapper
          format(TYPESCRIPT_SLICE_WRAPPER_TEMPLATE,
            plural_name: plural_name,
            singular_name: singular_name)
        end

        private

        def singular_name
          deleted_prefix = @ts_type.sub(/^Slice</, "") || @ts_type
          deleted_prefix.sub(/>$/, "") || @ts_type
        end

        def plural_name
          singular_name + "s"
        end

        # translate shopify_runtime_types with conversion wrapper functions for constructor assignments
        def translate_assignment_rhs
          rhs = @ts_type == "Slice<Str>" ? format(SLICE_SLICEUTF8_TEMPLATE, name: @name) : @name
          format(SLICE_ASSIGNMENT_WRAPPER_TEMPLATE,
            singular_name: singular_name,
            value_name: rhs)
        end

        # translate shopify_runtime_types to TS types for constructor parameter arguments
        def translate_constructor_type
          array_name = Type::CTOR_TYPE_TRANSLATIONS[singular_name] || singular_name
          format("Array<%{array_name}>", array_name: array_name)
        end
      end
    end
  end
end
