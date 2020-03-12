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
            empty_state: './node_modules/.bin/generate-node-app empty-state-page',
            two_column: './node_modules/.bin/generate-node-app two-column-page',
            annotated: './node_modules/.bin/generate-node-app settings-page',
            list: './node_modules/.bin/generate-node-app list-page',
            billing_recurring: './node_modules/.bin/generate-node-app recurring-billing',
            billing_one_time: './node_modules/.bin/generate-node-app one-time-billing',
            webhook: './node_modules/.bin/generate-node-app webhook',
          }
        end

        def page_types
          {
            'empty-state' => :empty_state,
            'list' => :list,
            'two-column' => :two_column,
            'annotated' => :annotated,
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
