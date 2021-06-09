# frozen_string_literal: true

module Script
  module Layers
    module Application
      class ScriptApis
        def self.get(type:)
          Infrastructure::ScriptApiRepository.new.get(type)
        end

        def self.types
          Infrastructure::ScriptApiRepository.new.all_types
        end

        def self.available_types
          Infrastructure::ScriptApiRepository.new.all.select do |ep|
            next false if ep.deprecated?
            !ep.beta? || ShopifyCli::Feature.enabled?(:scripts_beta_apis)
          end.map(&:type)
        end

        def self.deprecated_types
          Infrastructure::ScriptApiRepository.new
            .all
            .select(&:deprecated?)
            .map(&:type)
        end

        def self.languages(type:)
          get(type: type).sdks.all.map do |sdk|
            next nil if sdk.beta? && !ShopifyCli::Feature.enabled?(:scripts_beta_languages)
            sdk.class.language
          end.compact
        end

        def self.supported_language?(type:, language:)
          languages(type: type).include?(language.downcase)
        end
      end
    end
  end
end
