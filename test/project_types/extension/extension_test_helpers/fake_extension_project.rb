# typed: ignore
# frozen_string_literal: true

module Extension
  module ExtensionTestHelpers
    class FakeExtensionProject < Extension::ExtensionProject
      include SmartProperties

      property :directory
      property :title
      property :type
      property :registration_id
      property :registration_uuid
      property :api_key
      property :api_secret

      def config
        {
          "project_type" => "extension",
          ExtensionProjectKeys::SPECIFICATION_IDENTIFIER_KEY => type,
        }
      end

      def env
        @env ||= ShopifyCLI::Resources::EnvFile.new(
          api_key: api_key,
          secret: api_secret,
          shop: "my-test-shop.myshopify.com",
          extra: {
            ExtensionProjectKeys::TITLE_KEY => title,
            ExtensionProjectKeys::REGISTRATION_ID_KEY => registration_id,
            ExtensionProjectKeys::REGISTRATION_UUID_KEY => registration_uuid,
          }
        )
      end
    end
  end
end
