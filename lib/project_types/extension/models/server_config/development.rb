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

        CURRENT_DIRECTORY = "."

        property  :root_dir, accepts: String, default: CURRENT_DIRECTORY
        property! :build_dir, accepts: String, default: "build"
        property  :template, accepts: VALID_TEMPLATES
        property  :renderer, accepts: ServerConfig::DevelopmentRenderer
        property  :entries, accepts: ServerConfig::DevelopmentEntries
        property  :resource, accepts: ServerConfig::DevelopmentResource

        def self.find(type)
          case type.downcase
          when "web_pixel_extension"
            ["javascript"]
          else
            VALID_TEMPLATES
          end
        end
      end
    end
  end
end
