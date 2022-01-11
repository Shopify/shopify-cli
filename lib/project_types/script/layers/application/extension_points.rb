# frozen_string_literal: true

module Script
  module Layers
    module Application
      class ExtensionPoints
        class << self
          def get(type:)
            extension_point_repository.get_extension_point(type)
          end

          def types
            extension_point_repository.extension_point_types
          end

          def available_types
            extension_point_repository.extension_points.select do |ep|
              next false if ep.deprecated?
              !ep.beta? || include_beta_extension_points?
            end.map(&:type)
          end

          def deprecated_types
            extension_point_repository
              .extension_points
              .select(&:deprecated?)
              .map(&:type)
          end

          def all_languages
            extension_point_repository
              .extension_points
              .map { |ep| ep.library_languages(include_betas: include_beta_languages?) }
              .flatten
              .uniq
          end

          def languages(type:)
            get(type: type).library_languages(include_betas: include_beta_languages?)
          end

          def supported_language?(type:, language:)
            languages(type: type).include?(language.downcase)
          end

          private

          def extension_point_repository
            Infrastructure::ExtensionPointRepository.new
          end

          def include_beta_languages?
            ShopifyCLI::Feature.enabled?(:scripts_beta_languages)
          end

          def include_beta_extension_points?
            ShopifyCLI::Feature.enabled?(:scripts_beta_extension_points)
          end
        end
      end
    end
  end
end
