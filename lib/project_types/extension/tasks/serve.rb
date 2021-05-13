# frozen_string_literal: true
require "shopify_cli"

module Extension
  module Tasks
    class Serve < ShopifyCli::Task
      include SmartProperties

      property! :context, accepts: ShopifyCli::Context

      YARN_SERVE_COMMAND = %w(server)
      NPM_SERVE_COMMAND = %w(run-script server)

      def call
        CLI::UI::Frame.open(context.message("serve.frame_title")) do
          success = ShopifyCli::JsSystem.call(context, yarn: YARN_SERVE_COMMAND, npm: NPM_SERVE_COMMAND)
          context.abort(context.message("serve.serve_failure_message")) unless success
        end
      end
    end
  end
end
