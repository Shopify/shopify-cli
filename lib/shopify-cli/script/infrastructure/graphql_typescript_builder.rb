# frozen_string_literal: true
require "graphql"
require_relative "type_translator"
require_relative "singular_type"
require_relative "plural_type"
require_relative "type"

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class GraphQLTypeScriptBuilder
        GRAPHQL_DEFAULT_TYPES = [
          "Boolean",
          "String",
          "Int",
          "__Schema",
          "__Type",
          "__Field",
          "__Directive",
          "__EnumValue",
          "__InputValue",
          "__TypeKind",
          "__DirectiveLocation",
          "Float",
          "ID",
        ].freeze

        TYPESCRIPT_TYPE_FILE_TEMPLATE =
          <<~HEREDOC
            /*
             %{header_warning_message},
             */
            import { Slice, Str, ID, Int, Float } from \"../shopify_runtime_types\";
  
            %{slice_wrapper_definitions}
            %{type_definitions}
          HEREDOC
  
        TYPESCRIPT_TYPE_TEMPLATE =
          <<~HEREDOC
            @unmanaged
            export class %{name} {
            %{fields}
  
            %{constructor}}
          HEREDOC

        TYPESCRIPT_FIELD_TEMPLATE = "  public %{name}: %{type};"
        TYPESCRIPT_CONSTRUCTOR_ARG_TEMPLATE = "%{name}: %{type}"
        TYPESCRIPT_ASSIGNMENT_TEMPLATE = "    this.%{lhs} = %{rhs};"
        TYPESCRIPT_CONSTRUCTOR_TEMPLATE =
          <<~HEREDOC
              constructor(%{args}) {
            %{assignments}
              }
          HEREDOC

        QUERY_NAME = "Query"

        private_constant :GRAPHQL_DEFAULT_TYPES, :TYPESCRIPT_TYPE_FILE_TEMPLATE, :TYPESCRIPT_TYPE_TEMPLATE,
         :TYPESCRIPT_FIELD_TEMPLATE, :TYPESCRIPT_CONSTRUCTOR_ARG_TEMPLATE, :TYPESCRIPT_ASSIGNMENT_TEMPLATE,
         :TYPESCRIPT_CONSTRUCTOR_TEMPLATE, :QUERY_NAME

        def build(schema, header_warning_message)
          @types = parse(schema)
          @query_types = @types.find { |type| type[:name] == QUERY_NAME }
          @non_query_types = @types.select { |type| type[:name] != QUERY_NAME }
          format(TYPESCRIPT_TYPE_FILE_TEMPLATE,
            header_warning_message: header_warning_message,
            slice_wrapper_definitions: build_slice_wrapper_template(@query_types),
            type_definitions: @non_query_types.map { |type| build_type_template(type) }
        .join("\n"))
        end

        private

        def parse(schema)
          GraphQL::Schema
            .from_definition(schema)
            .types
            .reject { |type| GRAPHQL_DEFAULT_TYPES.include?(type) }
            .map do |name, type|
              {
                name: name,
                fields: get_fields(type).values.map { |f| field_hash(f) },
              }
            end
        end

        def get_fields(type)
          type.kind.input_object? ? type.input_fields : type.fields
        end

        def field_hash(field)
          {
            name: field.name,
            type: TypeTranslator.new.translate(field.type.to_s, field.name),
          }
        end

        def build_slice_wrapper_template(type)
          type[:fields]
            .map do |f|
              f[:type].wrapper
            end.join("\n\n") if type
        end

        def build_type_template(type)
          format(TYPESCRIPT_TYPE_TEMPLATE,
                name: type[:name],
                fields: build_fields(type),
                constructor: build_constructor(type))
        end

        def build_fields(type)
          type[:fields]
            .map { |f| format(TYPESCRIPT_FIELD_TEMPLATE, name: f[:name], type: f[:type].ts_type) }
            .join("\n")
        end

        def build_constructor(type)
          format(TYPESCRIPT_CONSTRUCTOR_TEMPLATE, args: build_args(type), assignments: build_assignments(type))
        end

        def build_args(type)
          type[:fields]
            .map do |f|
              format(TYPESCRIPT_CONSTRUCTOR_ARG_TEMPLATE, name: f[:name], type: f[:type].constructor_type)
            end.join(", ")
        end

        def build_assignments(type)
          type[:fields]
            .map do |f|
              format(TYPESCRIPT_ASSIGNMENT_TEMPLATE, lhs: f[:name], rhs: f[:type].assignment_rhs_type)
            end.join("\n")
        end
      end
    end
  end
end
