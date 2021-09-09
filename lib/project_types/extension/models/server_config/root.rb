# frozen_string_literal: true

module Extension
  module Models
    module ServerConfig
      class Root < Base
        include SmartProperties

        property! :port, accepts: Integer, default: 39351
        property! :extensions, accepts: [ServerConfig::Extension]

        def to_yaml
          to_h.to_yaml.gsub("---\n", "")
        end
      end
    end
  end
end
