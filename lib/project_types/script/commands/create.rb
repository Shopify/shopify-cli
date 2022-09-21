# frozen_string_literal: true

module Script
  class Command
    class Create < ShopifyCLI::Command::SubCommand
      hidden_feature

      options do |parser, flags|
        parser.on("--title=TITLE") { |title| flags[:title] = title }
        parser.on("--api=API_NAME") { |ep_name| flags[:extension_point] = ep_name }
        parser.on("--language=LANGUAGE") { |language| flags[:language] = language }
        parser.on("--branch=BRANCH") { |branch| flags[:branch] = branch }
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
