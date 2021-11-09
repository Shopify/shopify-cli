# frozen_string_literal: true

module Extension
  module Models
    module ServerConfig
      class App < Base
        include SmartProperties

        property! :api_key, accepts: String
      end
    end
  end
end
