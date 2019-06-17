# frozen_string_literal: true
require 'shopify_cli'

module ShopifyCli
  module Helpers
    class SchemaParser
      include SmartProperties

      property :schema

      def types
        @types = schema["data"]["__schema"]["types"]
      end

      def [](name)
        types.find do |object|
          object['name'] == name.to_s
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
