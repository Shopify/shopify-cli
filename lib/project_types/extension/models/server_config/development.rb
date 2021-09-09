module Extension
  module Models
    module ServerConfig
      class Development < Base
        include SmartProperties
        VALID_TEMPLATES = [
          "javascript",
          "javascript-react",
          "typescript",
          "typescript-react",
        ]

        property! :build_dir, accepts: String, default: "build"
        property! :root_dir, accepts: String
        property! :template, accepts: VALID_TEMPLATES
        property! :renderer, accepts: ServerConfig::DevelopmentRenderer
        property! :entries, accepts: ServerConfig::DevelopmentEntries
      end
    end
  end
end
