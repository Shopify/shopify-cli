# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class ExtensionPointRepository
        def get_extension_point(type)
          config = fetch_extension_point_config(type)

          return Domain::UnknownExtensionPoint.new(type) if config.nil?

          Domain::ExtensionPoint.new(type, config)
        end

        def extension_points
          extension_point_configs.map do |type, extension_point_config|
            Domain::ExtensionPoint.new(type, extension_point_config)
          end
        end

        def extension_point_types
          extension_point_configs.keys
        end

        private

        def fetch_extension_point_config(type)
          extension_point_configs[type]
        end

        def extension_point_configs
          @extension_points ||= begin
            require "yaml"
            YAML.load_file(Project.project_filepath("config/extension_points.yml"))
          end
        end
      end
    end
  end
end
