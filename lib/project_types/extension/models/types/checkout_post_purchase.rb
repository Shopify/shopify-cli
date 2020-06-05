# frozen_string_literal: true
require 'base64'

module Extension
  module Models
    module Types
      class CheckoutPostPurchase < Models::Type
        IDENTIFIER = 'CHECKOUT_POST_PURCHASE'

        def create(directory_name, context)
          Features::Argo.checkout.create(directory_name, IDENTIFIER, context)
        end

        def config(context)
          Features::Argo.checkout.config(context)
        end
      end
    end
  end
end
