# frozen_string_literal: true
require 'shopify_cli'

module Extension
  module Tasks
    class CreateExtension < ShopifyCli::Task
      def call(context:, api_key:, type:, title:)
        response = ShopifyCli::Helpers::PartnersAPI.query(
          context,
          'extension_create',
          api_key: api_key,
          type: type,
          title: title
        )

        response_to_registration(response)
      end

      private

      def response_to_registration(response)
        registration_hash = response.dig('data', 'extensionCreate', 'extensionRegistration')
        return nil if registration_hash.nil?

        Models::Registration.new(
          id: registration_hash['id'].to_i,
          type: registration_hash['type'],
          title: registration_hash['title']
        )
      end
    end
  end
end
