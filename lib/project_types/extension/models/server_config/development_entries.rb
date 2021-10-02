# frozen_string_literal: true

module Extension
  module Models
    module ServerConfig
      class DevelopmentEntries < Base
        include SmartProperties

        JAVASCRIPT = "javascript"
        JAVASCRIPT_REACT = "javascript-react"
        TYPESCRIPT = "typescript"
        TYPESCRIPT_REACT = "typescript-react"

        VALID_ENTRY_POINTS = [
          "src/index.js",
          "src/index.jsx",
          "src/index.ts",
          "src/index.tsx",
        ]

        property! :main, accepts: VALID_ENTRY_POINTS

        def self.find(template)
          case template
          when JAVASCRIPT
            new(main: "src/index.js")
          when JAVASCRIPT_REACT
            new(main: "src/index.jsx")
          when TYPESCRIPT
            new(main: "src/index.ts")
          when TYPESCRIPT_REACT
            new(main: "src/index.tsx")
          end
        end
      end
    end
  end
end
