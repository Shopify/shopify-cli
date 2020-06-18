# frozen_string_literal: true
require 'shopify_cli'

module Extension
  class ExtensionProject < ShopifyCli::Project
    class << self
      def write_cli_file(context:, type:)
        ShopifyCli::Project.write(
          context,
          project_type: :extension,
          organization_id: nil,
          "#{ExtensionProjectKeys::EXTENSION_TYPE_KEY}": type
        )
      end

      def write_env_file(context:, title:, api_key: '', api_secret: '', registration_id: nil)
        ShopifyCli::Resources::EnvFile.new(
          api_key: api_key,
          secret: api_secret,
          extra: {
            ExtensionProjectKeys::TITLE_KEY => title,
            ExtensionProjectKeys::REGISTRATION_ID_KEY => registration_id,
          }.compact
        ).write(context)

        self.current.reload unless project_empty?
      end

      private

      def project_empty?
        directory(Dir.pwd).nil?
      end
    end

    def app
      Models::App.new(api_key: env['api_key'], secret: env['secret'])
    end

    def registered?
      property_present?('api_key') && property_present?('secret') && registration_id?
    end

    def title
      get_extra_field(ExtensionProjectKeys::TITLE_KEY)
    end

    def extension_type_identifier
      config[ExtensionProjectKeys::EXTENSION_TYPE_KEY]
    end

    def registration_id?
      extra_property_present?(ExtensionProjectKeys::REGISTRATION_ID_KEY) &&
        is_integer?(get_extra_field(ExtensionProjectKeys::REGISTRATION_ID_KEY)) &&
        registration_id > 0
    end

    def registration_id
      get_extra_field(ExtensionProjectKeys::REGISTRATION_ID_KEY).to_i
    end

    def reload
      @env = nil
    end

    private

    def get_extra_field(key)
      extra = env[:extra] || {}
      extra[key]
    end

    def extra_property_present?(key)
      env[:extra].key?(key) && !get_extra_field(key).nil?
    end

    def property_present?(key)
      !env[key].nil? && !env[key].strip.empty?
    end

    def is_integer?(value)
      value.to_i.to_s == value.to_s
    end
  end
end
