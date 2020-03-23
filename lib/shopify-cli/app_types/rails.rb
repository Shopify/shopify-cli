# frozen_string_literal: true
require 'shopify_cli'

module ShopifyCli
  module AppTypes
    class Rails < AppType
      include ShopifyCli::Helpers

      class << self
        def description
          'rails embedded app'
        end

        def callback_url
          "/auth/shopify/callback"
        end
      end
    end
  end
end
