require 'shopify_cli'

module ShopifyCli
  module Commands
    class Populate
      class Resource
        include SmartProperties

        property :ctx, required: true, accepts: ShopifyCli::Context

        attr_accessor :api

        def initialize(*)
          super
          token = Helpers::AccessToken.read(ctx)
          @api = Helpers::API.new(ctx: ctx, token: token)
        end

        def mutation
          raise NotImplementedError
        end

        def message
          raise NotImplementedError
        end

        def populate(count)
          count.times do
            run_mutation
          end
        end

        def run_mutation
          body = @api.mutation_body(mutation)
          resp = @api.graphql_post(body)
          ctx.done(message(resp['data']))
        end

        def admin_url(type, id)
          "https://#{ctx.project.env.shop}/admin/#{type}s/#{id}"
        end
      end
    end
  end
end
