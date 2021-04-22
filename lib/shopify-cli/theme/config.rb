# frozen_string_literal: true
require "yaml"
require "pathname"

module ShopifyCli
  module Theme
    class Config
      NAME = "config.yml"

      attr_reader :root

      def initialize(root = ".", attributes = {})
        @root = root
        @attributes = attributes
      end

      def self.from_path(root, environment: "development")
        root = Pathname.new(root)
        file = root.join(NAME)

        attributes = if file.exist?
          YAML.load_file(file)[environment]
        else
          {}
        end

        new(root, attributes)
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
