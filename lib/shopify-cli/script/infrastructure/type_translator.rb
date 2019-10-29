
module ShopifyCli
  module ScriptModule
    module Infrastructure
      class TypeTranslator
        SLICE_TEMPLATE = "Slice<%{inner}>"
        GRAPHQL_TO_TS_TRANSLATIONS = { # potential name change
          "String" => "Str",
          "Boolean" => "bool",
        }.freeze

        def translate(graphql_type, name)
          ts_type = graphql_to_ts_type(graphql_type)
          slice?(ts_type) ? PluralType.new(graphql_type, name, ts_type) : SingularType.new(graphql_type, name, ts_type)
        end

        private

        def slice?(ts_type)
          ts_type.start_with?("Slice<")
        end

        def graphql_to_ts_type(graphql_type)
          graphql_type = graphql_type.chomp("!")

          return format(SLICE_TEMPLATE,
            inner: graphql_to_ts_type(graphql_type[1..-2])) if graphql_type.start_with?("[")

          GRAPHQL_TO_TS_TRANSLATIONS.key?(graphql_type) ? GRAPHQL_TO_TS_TRANSLATIONS[graphql_type] : graphql_type
        end
      end
    end
  end
end
