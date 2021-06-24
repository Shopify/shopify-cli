# frozen_string_literal: true
require "shopify_cli"

module Extension
  class Command
    class Build < ExtensionCommand
      hidden_feature

      prerequisite_task ensure_project_type: :extension

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
        ShopifyCli::Context.new.message("build.help", ShopifyCli::TOOL_NAME)
      end
    end
  end
end
