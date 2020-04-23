# frozen_string_literal: true
require 'shopify_cli'

module Extension
  module Tasks
    class UpdateDraft < ShopifyCli::Task
      def call(context:, api_key:, registration_id:, config:, extension_context:)
        response = ShopifyCli::PartnersAPI.query(
          context,
          'extension_update_draft',
          api_key: api_key,
          registration_id: registration_id,
          config: config,
          context: extension_context
        )

        response_to_version(response)
      end

      private

      def response_to_version(response)
        version_hash = response.dig('data', 'extensionUpdateDraft', 'extensionVersion')
        return nil if version_hash.nil?

        Models::Version.new(
          registration_id: version_hash['registrationId'].to_i,
          context: version_hash['context']
        )
      end
    end
  end
end
