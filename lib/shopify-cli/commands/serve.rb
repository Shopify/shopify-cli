# frozen_string_literal: true

require 'shopify_cli'

module ShopifyCli
  module Commands
    class Serve < ShopifyCli::Command
      prerequisite_task :tunnel

      def call(*)
        project = ShopifyCli::Project.current
        @ctx.system(project.app_type.serve_command(@ctx))
      end

      def self.help
        <<~HELP
          Run your projects server.
          Usage: {{command:#{ShopifyCli::TOOL_NAME} serve}}
        HELP
      end
    end
  end
end
