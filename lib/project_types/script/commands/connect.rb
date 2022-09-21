# frozen_string_literal: true
module Script
  class Command
    class Connect < ShopifyCLI::Command::SubCommand
      hidden_feature

      def call(_args, _)
        @ctx.abort(@ctx.message("script.deprecated"))
      end

      def self.help
        ShopifyCLI::Context.new.message("script.deprecated")
      end
    end
  end
end
