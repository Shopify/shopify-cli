# frozen_string_literal: true
require 'shopify_cli'

module ShopifyCli
  module Helpers
    module SchemaParser
      def get_types_by_name(schema, name)
        all_types = schema["data"]["__schema"]["types"]

        all_types.find do |object|
          object["name"] == name
        end
      end

      def get_names_from_enum(enum)
        enum["enumValues"].map do |object|
          object["name"]
        end
      end
    end
  end
end
