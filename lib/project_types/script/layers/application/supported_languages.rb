# frozen_string_literal: true

module Script
  module Layers
    module Application
      class SupportedLanguages
        STABLE_LANGUAGES = %w(AssemblyScript)
        BETA_LANGUAGES = %w(Rust)
        private_constant :STABLE_LANGUAGES, :BETA_LANGUAGES

        def self.all
          languages = STABLE_LANGUAGES
          languages += BETA_LANGUAGES if ShopifyCli::Feature.enabled?(:scripts_beta_languages)
          languages
        end
      end
    end
  end
end
