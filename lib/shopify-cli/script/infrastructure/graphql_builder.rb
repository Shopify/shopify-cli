# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class GraphQLBuilder
        GRAPHQL_LANGUAGE_BUILDERS = {
          "ts" => Infrastructure::GraphQLTypeScriptBuilder,
        }

        def self.from(language)
          return NoopGraphQLBuilder.new unless GRAPHQL_LANGUAGE_BUILDERS.include?(language)
          GRAPHQL_LANGUAGE_BUILDERS[language].new
        end
      end

      class NoopGraphQLBuilder
        def build(schema, header_warning_message); end
      end
    end
  end
end
