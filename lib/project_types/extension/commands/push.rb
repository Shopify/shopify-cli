# frozen_string_literal: true
require "shopify_cli"

module Extension
  class Command
    class Push < ExtensionCommand
      prerequisite_task ensure_project_type: :extension

      TIME_DISPLAY_FORMAT = "%B %d, %Y %H:%M:%S %Z"

      def call(args, name)
        Command::Register.new(@ctx).call(args, name) unless project.registered?
        Command::Build.new(@ctx).call(args, name) unless specification_handler.specification.options[:skip_build]
        CLI::UI::Frame.open(@ctx.message("push.frame_title")) do
          updated_draft_version = update_draft
          show_message(updated_draft_version)
        end
      end

      def self.help
        ShopifyCLI::Context.new.message("push.help", ShopifyCLI::TOOL_NAME)
      end

      private

      def show_message(draft)
        draft.validation_errors.empty? ? output_success_messages(draft) : output_validation_errors(draft)
      end

      def output_success_messages(draft)
        @ctx.puts(@ctx.message("push.success_confirmation", project.title, format_time(draft.last_user_interaction_at)))
        @ctx.puts(@ctx.message("push.success_info", draft.location))
      end

      def output_validation_errors(draft)
        @ctx.puts(@ctx.message("push.pushed_with_errors", format_time(draft.last_user_interaction_at)))

        draft.validation_errors.each do |error|
          @ctx.puts(format("{{x}} %s: %s", error.field.last, error.message))
        end

        @ctx.puts(@ctx.message("push.push_with_errors_info"))
      end

      def format_time(time)
        time.utc.strftime(TIME_DISPLAY_FORMAT)
      end

      def with_waiting_text
        @ctx.puts(@ctx.message("push.waiting_text"))
        yield
      end

      def update_draft
        with_waiting_text do
          Tasks::UpdateDraft.call(
            context: @ctx,
            api_key: project.app.api_key,
            registration_id: project.registration_id,
            config: specification_handler.config(@ctx),
            extension_context: specification_handler.extension_context(@ctx)
          )
        end
      rescue Extension::Errors::ExtensionError => e
        @ctx.abort(e)
      end
    end
  end
end
