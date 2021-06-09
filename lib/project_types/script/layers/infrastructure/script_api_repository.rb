# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class ScriptApiRepository
        def get(type)
          Domain::ScriptApi.new(type, fetch_script_api(type))
        end

        def all
          script_api_configs.map do |type, script_api_config|
            Domain::ScriptApi.new(type, script_api_config)
          end
        end

        def all_types
          script_api_configs.keys
        end

        private

        def fetch_script_api(type)
          raise Domain::Errors::InvalidScriptApiError, type unless script_api_configs[type]
          script_api_configs[type]
        end

        def script_api_configs
          @script_apis ||= begin
            require "yaml"
            YAML.load_file(Project.project_filepath("config/script_apis.yml"))
          end
        end
      end
    end
  end
end
