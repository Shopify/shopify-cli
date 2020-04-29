# frozen_string_literal: true
require 'shopify_cli'

module Extension
  module Commands
    class Push < ShopifyCli::Command

      def call(*)
        @project = ExtensionProject.current
        run_pack_command

        CLI::UI::Frame.open(Content::Push::FRAME_TITLE) do
          @project.registration_id? ? update_draft : confirm_before_creating_extension

          @ctx.puts(Content::Push::SUCCESS_CONFIRMATION)
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

      def run_pack_command
        pack_command = Commands::Pack.new
        pack_command.ctx = @ctx
        pack_command.call({}, :push)
      end

      def update_draft
        @ctx.puts(Content::Push::WAITING_TEXT)

        Tasks::UpdateDraft.call(
          context: @ctx,
          api_key: @project.env['api_key'],
          registration_id: @project.registration_id,
          config: @project.extension_type.config(@ctx),
          extension_context: @project.extension_type.extension_context(@ctx)
        )
      end

      def confirm_before_creating_extension
        @ctx.puts(Content::Push::CREATE_CONFIRM_INFO)
        continue_with_creation = CLI::UI::Prompt.confirm(Content::Push::CREATE_CONFIRM_QUESTION)
        continue_with_creation ? create_extension : @ctx.abort(Content::Push::CREATE_ABORT)
      end

      def create_extension
        @ctx.puts(Content::Push::WAITING_TEXT)

        registration = Tasks::CreateExtension.call(
          context: @ctx,
          api_key: @project.env['api_key'],
          type: @project.extension_type.identifier,
          title: 'Testing the CLI',
          config: @project.extension_type.config(@ctx),
          extension_context: @project.extension_type.extension_context(@ctx)
        )

        @project.set_registration_id(@ctx, registration.id)
      end
    end
  end
end
