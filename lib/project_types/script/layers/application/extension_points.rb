# frozen_string_literal: true

module Script
  module Layers
    module Application
      class ExtensionPoints
        def self.get(type:)
          Infrastructure::ExtensionPointRepository.new.get_extension_point(type)
        end

        def self.types
          Infrastructure::ExtensionPointRepository.new.extension_point_types
        end

        def self.available_types
          Infrastructure::ExtensionPointRepository.new.extension_points.select do |ep|
            next false if ep.deprecated?
            !ep.beta? || ShopifyCLI::Feature.enabled?(:scripts_beta_extension_points)
          end.map(&:type)
        end

        def self.deprecated_types
          Infrastructure::ExtensionPointRepository.new
            .extension_points
            .select(&:deprecated?)
            .map(&:type)
        end

        def self.languages(type:)
          get(type: type).sdks.all.map do |sdk|
            next nil if sdk.beta? && !ShopifyCLI::Feature.enabled?(:scripts_beta_languages)
            sdk.language
          end.compact
        end

        def self.supported_language?(type:, language:)
          languages(type: type).include?(language.downcase)
        end
      end
    end
  end
end
