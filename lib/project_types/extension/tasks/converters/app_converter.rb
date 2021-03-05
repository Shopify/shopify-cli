# frozen_string_literal: true
require "shopify_cli"

module Extension
  module Tasks
    module Converters
      module AppConverter
        API_KEY_FIELD = "apiKey"
        API_SECRET_KEYS_FIELD = "apiSecretKeys"
        API_SECRET_FIELD = "secret"
        TITLE_FIELD = "title"
        ORGANIZATION_NAME_FIELD = "businessName"

        def self.from_hash(hash, organization = {})
          return nil if hash.nil?

          Models::App.new(
            api_key: hash[API_KEY_FIELD],
            secret: hash[API_SECRET_KEYS_FIELD].first[API_SECRET_FIELD],
            title: hash[TITLE_FIELD],
            business_name: organization[ORGANIZATION_NAME_FIELD]
          )
        end
      end
    end
  end
end
