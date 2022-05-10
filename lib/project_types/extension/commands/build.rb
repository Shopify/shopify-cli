# frozen_string_literal: true
require "shopify_cli"

module Extension
  class Command
    class Build < ExtensionCommand
      prerequisite_task ensure_project_type: :extension

      YARN_BUILD_COMMAND = %w(build)
      NPM_BUILD_COMMAND = %w(run-script build)

      def call(_args, _command_name)
        project = ExtensionProject.current(force_reload: true)
        return run_new_flow(project) if supports_development_server?(project.specification_identifier)
        run_legacy_flow
      end

      def self.help
        ShopifyCLI::Context.new.message("build.help", ShopifyCLI::TOOL_NAME)
      end

      private

      def run_new_flow(project)
        Tasks::ExecuteCommands
          .build(
            context: @ctx,
            config_file_path: specification_handler.server_config_path,
            type: project.specification_identifier.downcase
          )
          .then { |output| @ctx.puts(output) }
          .unwrap do |error|
            raise ShopifyCLI::Abort, error.message unless error.nil?
          end
      end

      def run_legacy_flow
        system = ShopifyCLI::JsSystem.new(ctx: @ctx)

        CLI::UI::Frame.open(@ctx.message("build.frame_title", system.package_manager)) do
          success = system.call(yarn: YARN_BUILD_COMMAND, npm: NPM_BUILD_COMMAND)
          @ctx.abort(@ctx.message("build.build_failure_message")) unless success
        end
      end

      def supports_development_server?(type)
        Models::DevelopmentServerRequirements.supported?(type)
      end
    end
  end
end
