# frozen_string_literal: true
require "shopify_cli"

module Extension
  module Commands
    class Build < ExtensionCommand
      hidden_feature

      YARN_BUILD_COMMAND = %w(build)
      NPM_BUILD_COMMAND = %w(run-script build)

      def call(_args, _command_name)
        system = ShopifyCli::JsSystem.new(ctx: @ctx)

        CLI::UI::Frame.open(@ctx.message("build.frame_title", system.package_manager)) do
          success = system.call(yarn: YARN_BUILD_COMMAND, npm: NPM_BUILD_COMMAND)
          @ctx.abort(@ctx.message("build.build_failure_message")) unless success
        end
      end

      def self.help
        <<~HELP
          Build your extension to prepare for deployment.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} build}}
        HELP
      end
    end
  end
end
