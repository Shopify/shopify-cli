# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class SparseCheckoutDetails
        include SmartProperties
        property! :repo, accepts: String
        property! :branch, accepts: String
        property! :path, accepts: String
        property! :input_queries_enabled, accepts: [true, false]

        def ==(other)
          self.class == other.class &&
            self.class.properties.all? { |name, _| self[name] == other[name] }
        end

        def setup(ctx)
          ShopifyCLI::Git.sparse_checkout(repo, set_path, branch, ctx)
        end

        private

        def set_path
          paths = [path]
          unless input_queries_enabled
            paths << "!#{path}/#{ScriptProjectRepository::INPUT_QUERY_PATH}"
            paths << "!#{path}/schema.graphql"
          end
          paths.join(" ")
        end
      end
    end
  end
end
