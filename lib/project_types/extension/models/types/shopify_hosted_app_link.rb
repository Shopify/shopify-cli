# frozen_string_literal: true

module Extension
  module Models
    module Types
      class ShopifyHostedAppLink < Models::Type
        def identifier
          'SHOPIFY_HOSTED_APP_LINK'
        end

        def name
          'Shopify Hosted App Link'
        end

        def config(_context)
          {
            text: 'Test Based Text',
            url: 'https://www.test-onlh.com'
          }
        end

        def extension_context(_context)
          valid_extension_contexts.first
        end

        def valid_extension_contexts
          ['products#show']
        end
      end
    end
  end
end
