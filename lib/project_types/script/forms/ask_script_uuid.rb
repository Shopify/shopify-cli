# frozen_string_literal: true

module Script
  module Forms
    class AskScriptUuid < ShopifyCLI::Form
      attr_reader :uuid
      def ask
        scripts = @xargs
        if scripts.empty?
          raise ShopifyCLI::Abort, ctx.message("script.error.no_scripts_found_in_app")
        end

        unless CLI::UI::Prompt.confirm(ctx.message("script.application.ensure_env.ask_connect_to_existing_script"))
          raise ShopifyCLI::AbortSilent
        end

        @uuid =
          CLI::UI::Prompt.ask(ctx.message("script.application.ensure_env.ask_which_script_to_connect_to")) do |handler|
            scripts.each do |script|
              handler.option("#{script["title"]} (#{script["uuid"]})") { script["uuid"] }
            end
          end
      end
    end
  end
end
