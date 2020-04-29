# frozen_string_literal: true

require "project_types/script/test_helper"

module Script
  module Layers
    module Infrastructure
      class FakeScriptRepository
        def initialize
          @cache = {}
        end

        def create_script(language, extension_point, script_name)
          id = "#{language}/#{extension_point.type}/#{script_name}"
          @cache[id] = Domain::Script.new(id, script_name, extension_point, language)
        end

        def get_script(language, extension_point_type, script_name)
          id = "#{language}/#{extension_point_type}/#{script_name}"

          if @cache.key?(id)
            @cache[id]
          else
            raise ScriptNotFoundError.new(extension_point_type, script_name)
          end
        end

        def with_temp_build_context
          yield
        end
      end
    end
  end
end
