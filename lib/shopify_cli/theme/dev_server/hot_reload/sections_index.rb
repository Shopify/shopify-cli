# frozen_string_literal: true

module ShopifyCLI
  module Theme
    class DevServer
      class HotReload
        class SectionsIndex
          def initialize(theme)
            @theme = theme
          end

          def section_names_by_type
            index = {}

            files.each do |file|
              section_hash(file).each do |key, value|
                next unless key
                next unless value.is_a?(Hash)
                next unless (type = value&.dig("type"))

                index[type] = [] unless index[type]
                index[type] << key
              end
            end

            index
          end

          private

          def section_hash(file)
            content = JSON.parse(file.read)
            return [] unless content.is_a?(Hash)

            sections = content["sections"]
            return [] if sections.nil?

            sections
          rescue JSON::JSONError
            []
          end

          def files
            @theme.json_files.filter(&:template?)
          end
        end
      end
    end
  end
end
