# frozen_string_literal: true

require 'shopify_cli'

module ShopifyCli
  module Commands
    class Deploy < ShopifyCli::ContextualCommand
      unavailable_in_contexts 'deploy', [:top_level]
      override_in_contexts 'deploy', [:app, :script], 'shopify-cli/commands/deploy'
    end
  end
end
