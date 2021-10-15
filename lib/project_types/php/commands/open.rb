# frozen_string_literal: true

module PHP
  class Command
    class Open < ShopifyCLI::SubCommand
      def call(*)
        project = ShopifyCLI::Project.current
        @ctx.open_url!("#{project.env.host}/login?shop=#{project.env.shop}")
      end

      def self.help
        ShopifyCLI::Context.message("php.open.help", ShopifyCLI::TOOL_NAME)
      end
    end
  end
end
