# frozen_string_literal: true

module Extension
  module Models
    module ServerConfig
      class DevelopmentResource < Base
        include SmartProperties

        property! :url, accepts: String
      end
    end
  end
end
