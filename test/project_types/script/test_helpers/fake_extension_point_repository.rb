# frozen_string_literal: true

require "project_types/script/test_helper"

module TestHelpers
  class FakeExtensionPointRepository
    def initialize
      @cache = {}
    end

    def create_extension_point(type)
      @cache[type] = Script::Layers::Domain::ExtensionPoint.new(type, example_config(type))
    end

    def create_beta_extension_point(type)
      @cache[type] = Script::Layers::Domain::ExtensionPoint.new(type, beta_config(type))
    end

    def create_deprecated_extension_point(type)
      @cache[type] = Script::Layers::Domain::ExtensionPoint.new(type, deprecated_config(type))
    end

    def get_extension_point(type)
      if @cache.key?(type)
        @cache[type]
      else
        raise Script::Layers::Domain::Errors::InvalidExtensionPointError, type
      end
    end

    def extension_points
      @cache.values
    end

    def extension_point_types
      @cache.keys
    end

    def beta_config(type)
      {
        "domain" => "fake-domain",
        "libraries" => {
          "tinygo" => {
            "repo" => "fake-repo",
            "package" => type,
            "version" => "1",
          },
        },
        "beta" => true,
      }
    end

    def deprecated_config(type)
      example_config(type).merge({ "deprecated" => true })
    end

    def example_config(type)
      {
        "domain" => "fake-domain",
        "libraries" => {
          "assemblyscript" => {
            "repo" => "fake-repo",
            "package" => type,
            "version" => "1",
          },
          "rust" => {
            "beta" => true,
            "package" => type,
            "version" => "1",
          },
          "wasm" => {
            "beta" => true,
            "package" => type,
            "version" => "1",
          },
        },
      }
    end
  end
end
