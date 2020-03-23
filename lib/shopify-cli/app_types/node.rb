require 'shopify_cli'

module ShopifyCli
  module AppTypes
    class Node < AppType
      class << self
        def description
          'node embedded app'
        end

        def callback_url
          "/auth/callback"
        end
      end
    end
  end
end
