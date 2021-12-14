# frozen_string_literal: true

module Script
  module Forms
    class AskScriptUuid < ShopifyCLI::Form
      attr_reader :uuid
      def ask
        scripts = @xargs

        return if scripts.empty? ||
          !CLI::UI::Prompt.confirm(ctx.message("script.application.ensure_env.ask_connect_to_existing_script"))

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
