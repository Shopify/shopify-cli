# frozen_string_literal: true
module Script
  class Command
    class Connect < ShopifyCLI::Command::SubCommand
      prerequisite_task :ensure_authenticated
      prerequisite_task ensure_project_type: :script

      def call(_args, _)
        Layers::Application::ConnectApp.call(ctx: @ctx, force: true)
      end

      def self.help
        ShopifyCLI::Context.new.message("connect.help", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
      end
    end
  end
end
