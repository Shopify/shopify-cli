# frozen_string_literal: true
require 'shopify_cli'
require 'forwardable'

module Extension
  class ExtensionProject
    extend Forwardable
    include SmartProperties

    REGISTRATION_ID_KEY = 'EXTENSION_ID'
    EXTENSION_TYPE_KEY = 'EXTENSION_TYPE'
    TITLE_KEY = 'EXTENSION_TITLE'

    def_delegators :project, :env, :directory, :config

    property! :project, accepts: ShopifyCli::Project

    class << self
      def current
        ExtensionProject.new(project: ShopifyCli::Project.current)
      end

      def write_project_files(context:, api_key:, api_secret:, title:, type:)
        ShopifyCli::Project.write(context, :extension, EXTENSION_TYPE_KEY => type)
        ShopifyCli::Resources::EnvFile.new(
          api_key: api_key,
          secret: api_secret,
          extra: { TITLE_KEY => title }.compact
        ).write(context)
      end
    end

    def app
      Models::App.new(api_key: env['api_key'], secret: env['secret'])
    end

    def title
      get_extra_field(TITLE_KEY)
    end

    def extension_type
      Models::Type.load_type(config[EXTENSION_TYPE_KEY])
    end

    def registration_id?
      env[:extra].key?(REGISTRATION_ID_KEY) && registration_id > 0
    end

    def registration_id
      get_extra_field(REGISTRATION_ID_KEY).to_i
    end

    def set_registration_id(context, new_registration_id)
      return if registration_id == new_registration_id

      updated_extra = env[:extra].merge(REGISTRATION_ID_KEY => new_registration_id)
      env.update(context, :extra, updated_extra)
    end

    private

    def get_extra_field(key)
      extra = env[:extra]
      extra[key] unless extra.nil?
    end
  end
end
