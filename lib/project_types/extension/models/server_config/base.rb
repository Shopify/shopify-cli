# frozen_string_literal: true

module Extension
  module Models
    module ServerConfig
      class Base
        def to_h
          to_hash
        end

        def to_hash
          is_hashable = ->(obj) { obj.respond_to?(:to_hash) }
          is_collection_of_hashables = ->(obj) { obj.is_a?(Enumerable) && obj.all?(&is_hashable) }

          self.class.properties.each.reduce({}) do |data, (_, property)|
            data.merge(property.name.to_s => send(property.reader).yield_self do |value|
              case value
              when is_collection_of_hashables
                value.map { |element| element.to_hash.transform_keys(&:to_s) }
              when is_hashable
                value.to_hash.transform_keys(&:to_s)
              else
                value
              end
            end)
          end
        end
      end
    end
  end
end
