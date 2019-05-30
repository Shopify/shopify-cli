module ShopifyCli
  module Helpers
    module GraphQL
      autoload :Queries, 'shopify-cli/helpers/graphql/queries'

      def query_body(query, variables: {})
        JSON.dump(
          query: query,
          variables: variables,
        )
      end
    end
  end
end
