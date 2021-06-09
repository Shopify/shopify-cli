# frozen_string_literal: true

require "project_types/script/test_helper"

module TestHelpers
  class FakeScriptApiRepository
    def initialize
      @cache = {}
    end

    def create_script_api(type)
      @cache[type] = Script::Layers::Domain::ScriptApi.new(type, example_config(type))
    end

    def create_beta_script_api(type)
      @cache[type] = Script::Layers::Domain::ScriptApi.new(type, beta_config(type))
    end

    def create_deprecated_script_api(type)
      @cache[type] = Script::Layers::Domain::ScriptApi.new(type, deprecated_config(type))
    end

    def get(type)
      if @cache.key?(type)
        @cache[type]
      else
        raise Script::Layers::Domain::Errors::InvalidScriptApiError, type
      end
    end

    def all
      @cache.values
    end

    def all_types
      @cache.keys
    end

    private

    def beta_config(type)
      example_config(type).merge({ "beta" => true })
    end

    def deprecated_config(type)
      example_config(type).merge({ "deprecated" => true })
    end

    def example_config(type)
      {
        "assemblyscript" => {
          "package" => type,
          "version" => "1",
          "sdk" => "1",
        },
        "rust" => {
          "beta" => true,
          "package" => type,
          "version" => "1",
          "sdk" => "1",
        },
      }
    end
  end
end
