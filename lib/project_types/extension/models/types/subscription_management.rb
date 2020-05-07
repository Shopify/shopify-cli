# frozen_string_literal: true
require 'base64'

module Extension
  module Models
    module Types
      class SubscriptionManagement < Models::Type
        IDENTIFIER = 'SUBSCRIPTION_MANAGEMENT'

        def create(directory_name, context)
          Models::Types::Argo.create(directory_name, IDENTIFIER, context)
        end

        def config(context)
          Models::Types::Argo.config(context)
        end
      end
    end
  end
end
