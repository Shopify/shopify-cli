# frozen_string_literal: true

module Extension
  module Models
    module ServerConfig
      class Root < Base
        include SmartProperties

        property  :app, accepts: ServerConfig::App
        property! :extensions, accepts: Array, default: -> { [] }
        property! :port, accepts: Integer, default: 39351
        property  :public_url, accepts: String
        property  :store, accepts: String

        def to_yaml
          to_h.to_yaml.gsub("---\n", "")
        end
      end
    end
  end
end
