require 'shopify_cli'

module ShopifyCli
  module AppTypes
    class Node < AppType
      class << self
        def description
          'node embedded app'
        end

        def generate
          {
            billing_recurring: './node_modules/.bin/generate-node-app recurring-billing',
            billing_one_time: './node_modules/.bin/generate-node-app one-time-billing',
            webhook: './node_modules/.bin/generate-node-app webhook',
          }
        end

        def generate_command(selected_type)
          "#{generate[:webhook]} #{selected_type}"
        end

        def webhook_location
          "server/server.js"
        end

        def callback_url
          "/auth/callback"
        end
      end
    end
  end
end
