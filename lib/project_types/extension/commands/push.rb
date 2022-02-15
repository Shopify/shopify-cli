# frozen_string_literal: true
require "shopify_cli"

module Extension
  class Command
    class Push < ShopifyCLI::Command::SubCommand
      prerequisite_task ensure_project_type: :extension

      recommend_default_ruby_range

      options do |parser, flags|
        parser.on("--api-key=API_KEY") { |api_key| flags[:api_key] = api_key.gsub('"', "") }
        parser.on("--api-secret=API_SECRET") { |api_secret| flags[:api_secret] = api_secret.gsub('"', "") }
        parser.on("--extension-id=EXTENSION_ID") do |registration_id|
          flags[:registration_id] = registration_id.gsub('"', "")
        end
      end

      TIME_DISPLAY_FORMAT = "%B %d, %Y %H:%M:%S %Z"

      def call(args, name)
        project = Extension::Loaders::Project.load(
          context: @ctx,
          directory: Dir.pwd,
          api_key: options.flags[:api_key],
          api_secret: options.flags[:api_secret],
          registration_id: options.flags[:registration_id]
        )
        # on ci, registration id must be present
        registration_id = options.flags[:registration_id]
        check_registration(registration_id: registration_id, context: @ctx)

        specification_handler = Extension::Loaders::SpecificationHandler.load(project: project, context: @ctx)
        register_if_necessary(project: project, args: args, name: name)

        Command::Build.new(@ctx).call(args, name) unless specification_handler.specification.options[:skip_build]
        CLI::UI::Frame.open(@ctx.message("push.frame_title")) do
          updated_draft_version = update_draft(project: project, specification_handler: specification_handler)
          show_message(updated_draft_version, project: project)
        end
      end

      def register_if_necessary(project:, args:, name:)
        if ShopifyCLI::Environment.interactive? && !project.registered?
          Command::Register.new(@ctx).call(args, name)
        end
      end

      def check_registration(registration_id:, context:)
        if !ShopifyCLI::Environment.interactive? && (!registration_id || registration_id.empty?)
          message = context.message("errors.missing_push_options_ci", "--registration-id")
          message += context.message("errors.missing_push_options_ci_solution", ShopifyCLI::TOOL_NAME)
          raise ShopifyCLI::Abort,
            message
        end
      end

      def self.help
        ShopifyCLI::Context.new.message("push.help", ShopifyCLI::TOOL_NAME)
      end

      private

      def show_message(draft, project:)
        if draft.validation_errors.empty?
          output_success_messages(draft,
            project: project)
        else
          output_validation_errors(draft)
        end
      end

      def output_success_messages(draft, project:)
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

      def update_draft(project:, specification_handler:)
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
