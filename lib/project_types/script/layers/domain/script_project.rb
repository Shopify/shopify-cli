# frozen_string_literal: true

module Script
  module Layers
    module Domain
      class ScriptProject
        include SmartProperties

        property! :id, accepts: String
        property :env, accepts: ShopifyCli::Resources::EnvFile

        property! :extension_point_type, accepts: String
        property! :script_name, accepts: String
        property! :language, accepts: String

        property :config_ui, accepts: ConfigUi

        def initialize(*)
          super

          ShopifyCli::Core::Monorail.metadata = {
            "script_name" => script_name,
            "extension_point_type" => extension_point_type,
            "language" => language,
          }
        end

        def api_key
          env[:api_key]
        end
      end
    end
  end
end
