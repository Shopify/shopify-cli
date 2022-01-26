# frozen_string_literal: true
module Script
  class Command
    class Connect < ShopifyCLI::Command::SubCommand
      prerequisite_task :ensure_authenticated
      prerequisite_task ensure_project_type: :script

      recommend_node(
        from: ::Script::Layers::Infrastructure::Languages::TypeScriptProjectCreator::MIN_NODE_VERSION,
        to: ShopifyCLI::Constants::SupportedVersions::Node::TO
      )
      recommend_default_ruby_range

      def call(_args, _)
        Layers::Application::ConnectApp.call(ctx: @ctx, force: true)
      rescue StandardError => e
        UI::ErrorHandler.pretty_print_and_raise(e, failed_op: @ctx.message("script.connect.error.operation_failed"))
      end

      def self.help
        ShopifyCLI::Context.new.message("script.connect.help", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
      end
    end
  end
end
