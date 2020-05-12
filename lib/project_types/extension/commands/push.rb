# frozen_string_literal: true
require 'shopify_cli'

module Extension
  module Commands
    class Push < ShopifyCli::Command

      def call(args, name)
        @project = ExtensionProject.current

        Commands::Register.new(@ctx).call(args, name) unless @project.registered?
        Commands::Pack.new(@ctx).call(args, name)

        CLI::UI::Frame.open(Content::Push::FRAME_TITLE) do
          update_draft

          @ctx.puts(Content::Push::SUCCESS_CONFIRMATION % @project.title)
          @ctx.puts(Content::Push::SUCCESS_INFO)
        end
      end

      def self.help
        <<~HELP
          Push the current extension to the Partners Dashboard where you can create a version that can be published to merchants.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} push}}
        HELP
      end

      private

      def update_draft
        @ctx.puts(Content::Push::WAITING_TEXT)

        Tasks::UpdateDraft.call(
          context: @ctx,
          api_key: @project.app.api_key,
          registration_id: @project.registration_id,
          config: @project.extension_type.config(@ctx),
          extension_context: @project.extension_type.extension_context(@ctx)
        )
      end
    end
  end
end
