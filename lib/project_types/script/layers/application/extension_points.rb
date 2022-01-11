# frozen_string_literal: true

module Script
  module Layers
    module Application
      class ExtensionPoints
        class << self
          def get(type:)
            Infrastructure::ExtensionPointRepository.new.get_extension_point(type)
          end

          def types
            Infrastructure::ExtensionPointRepository.new.extension_point_types
          end

          def available_types
            Infrastructure::ExtensionPointRepository.new.extension_points.select do |ep|
              next false if ep.deprecated?
              !ep.beta? || ShopifyCLI::Feature.enabled?(:scripts_beta_extension_points)
            end.map(&:type)
          end

          def deprecated_types
            Infrastructure::ExtensionPointRepository.new
              .extension_points
              .select(&:deprecated?)
              .map(&:type)
          end

          def languages(type:)
            get(type: type).library_languages(include_betas: ShopifyCLI::Feature.enabled?(:scripts_beta_languages))
          end

          def supported_language?(type:, language:)
            languages(type: type).include?(language.downcase)
          end
        end
      end
    end
  end
end
