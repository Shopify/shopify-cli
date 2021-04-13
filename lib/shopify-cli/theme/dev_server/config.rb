# frozen_string_literal: true
require "yaml"

module ShopifyCli
  module Theme
    module DevServer
      class Config
        NAME = "config.yml"

        attr_reader :root

        def initialize(root, attributes = {})
          @root = root
          @attributes = attributes
          # TODO: valid config
        end

        def self.from_path(root, environment: "development")
          root = Pathname.new(root)
          new(root, YAML.load_file(root.join(NAME))[environment])
        end

        def to_h
          @attributes
        end

        def ignore_files
          @attributes["ignore_files"] || []
        end

        def ignores
          @attributes["ignores"] || []
        end
      end
    end
  end
end
