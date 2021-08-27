# frozen_string_literal: true

module Extension
  module Models
    module ServerConfig
      class DevelopmentEntries < Base
        include SmartProperties

        VALID_ENTRY_POINTS = [
          "src/index.js",
          "src/index.jsx",
          "src/index.ts",
          "src/index.tsx",
        ]

        property! :main, accepts: VALID_ENTRY_POINTS
      end
    end
  end
end
