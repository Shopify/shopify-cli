# frozen_string_literal: true
require "shopify_cli"

module Extension
  module Tasks
    module Converters
      module ProductConverter
        VARIANT_PATH = ["data", "products", "edges", 0, "node", "variants", "edges", 0, "node", "id"]

        def self.from_hash(hash)
          return nil if hash.nil?
          variant = hash.dig(*VARIANT_PATH)
          return unless variant
          Models::Product.new(
            variant_id: ShopifyCLI::API.gid_to_id(variant)
          )
        end
      end
    end
  end
end
