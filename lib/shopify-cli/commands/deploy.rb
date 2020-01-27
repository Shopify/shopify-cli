# frozen_string_literal: true

require 'shopify_cli'

module ShopifyCli
  module Commands
    class Deploy < ShopifyCli::ContextualCommand
      class << self
        def register_contextual_command
          project_type = Project.current.config['project_type']
          if project_type == :app || :script
            register_for_context 'deploy', project_type, 'shopify-cli/commands/deploy'
          end
        end
      end
    end
  end
end
