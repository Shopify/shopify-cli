# frozen_string_literal: true

module Script
  module Layers
    module Domain
      class ScriptProject
        include SmartProperties

        UUID_ENV_KEY = "UUID"

        property! :id, accepts: String
        property :env, accepts: ShopifyCLI::Resources::EnvFile

        property! :extension_point_type, accepts: String
        property! :title, accepts: String
        property  :description, accepts: String
        property! :language, accepts: String

        property :script_config, accepts: ScriptConfig
        property :input_query, accepts: String

        def initialize(*)
          super

          ShopifyCLI::Core::Monorail.metadata = {
            "script_name" => title,
            "extension_point_type" => extension_point_type,
            "language" => language,
          }
        end

        def api_key
          env&.api_key
        end

        def api_secret
          env&.secret
        end

        def uuid
          uuid_defined? && !raw_uuid.empty? ? raw_uuid : nil
        end

        def uuid_defined?
          !raw_uuid.nil?
        end

        def env_valid?
          api_key && api_secret && uuid_defined?
        end

        private

        def raw_uuid
          env&.extra&.[](UUID_ENV_KEY)
        end
      end
    end
  end
end
