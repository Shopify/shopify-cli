# frozen_string_literal: true

require 'shopify_cli'

module ShopifyCli
  module Commands
    class Deploy < ShopifyCli::ContextualCommand
      class << self
        def resolve_context
          if Project.current_context == :top_level
            unregister_for_context 'deploy'
          else
            project_type = Project.current.config['project_type']
            if [:app, :script].include?(project_type)
              override_for_context 'deploy', project_type, 'shopify-cli/commands/deploy'
            end
          end
        end
      end

      resolve_context
    end
  end
end
