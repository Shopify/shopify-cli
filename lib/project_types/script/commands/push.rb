# frozen_string_literal: true

module Script
  class Command
    class Push < ShopifyCLI::Command::SubCommand
      hidden_feature

      options do |parser, flags|
        parser.on("--force") { |t| flags[:force] = t }
        parser.on("--api-key=API_KEY") { |api_key| flags[:api_key] = api_key.gsub('"', "") }
        parser.on("--api-secret=API_SECRET") { |api_secret| flags[:api_secret] = api_secret.gsub('"', "") }
        parser.on("--uuid=UUID") do |uuid|
          flags[:uuid] = uuid.gsub('""', "")
        end
      end

      def call(_args, _)
        @ctx.abort(@ctx.message("script.deprecated"))
      end

      def self.help
        ShopifyCLI::Context.new.message("script.deprecated")
      end
    end
  end
end
