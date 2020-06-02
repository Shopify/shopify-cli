# frozen_string_literal: true

module Extension
  module ExtensionTestHelpers
    class FakeExtensionProject < Extension::ExtensionProject
      include SmartProperties

      property :directory
      property :title
      property :type
      property :registration_id
      property :api_key
      property :api_secret

      def config
        {
          ExtensionProjectKeys::EXTENSION_TYPE_KEY => type
        }
      end

      def env
        @env ||= ShopifyCli::Resources::EnvFile.new(
          api_key: api_key,
          secret: api_secret,
          extra: {
            ExtensionProjectKeys::TITLE_KEY => title,
            ExtensionProjectKeys::REGISTRATION_ID_KEY => registration_id
          }
        )
      end
    end
  end
end
