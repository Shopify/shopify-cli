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
          resp = @api.mutation(mutation)
          ctx.done(message(resp['data']))
        end

        def admin_url(type, id)
          "https://#{ctx.project.env.shop}/admin/#{type}s/#{id}"
        end

        def price
          format('%.2f', rand(1..10))
        end
      end
    end
  end
end
