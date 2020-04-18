# frozen_string_literal: true
require 'shopify_cli'

module Extension
  class ExtensionProject
    extend Forwardable
    include SmartProperties

    REGISTRATION_ID_KEY = 'EXTENSION_ID'
    EXTENSION_TYPE_KEY = 'EXTENSION_TYPE'

    def_delegators :project, :env, :directory, :config

    property! :project, accepts: ShopifyCli::Project

    class << self
      def current
        ExtensionProject.new(project: ShopifyCli::Project.current)
      end

      def write_project_files(context:, api_key:, api_secret:, type:)
        ShopifyCli::Project.write(context, :extension)

        ShopifyCli::Helpers::EnvFile.new(
          api_key: api_key,
          secret: api_secret,
          extra: {
            ExtensionProject::EXTENSION_TYPE_KEY => type
          }
        ).write(context)
      end
    end

    def registration_id?
      env[:extra].key?(REGISTRATION_ID_KEY) && registration_id > 0
    end

    def registration_id
      env[:extra][REGISTRATION_ID_KEY].to_i
    end

    def set_registration_id(context, new_registration_id)
      return if registration_id == new_registration_id
      env.update(context, :extra, env[:extra].merge(REGISTRATION_ID_KEY => new_registration_id))
    end

    def extension_type
      Models::Type.load_type(env[:extra][EXTENSION_TYPE_KEY])
    end
  end
end
