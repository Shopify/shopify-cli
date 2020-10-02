# frozen_string_literal: true
module Theme
  module Commands
    class Serve < ShopifyCli::Command
      options do |parser, flags|
        parser.on('--env=ENV') { |env| flags[:env] = env }
      end

      def call(*)
        CLI::UI::Frame.open(@ctx.message('theme.checking_themekit')) do
          Themekit.ensure_themekit_installed(@ctx)
        end

        CLI::UI::Frame.open(@ctx.message('theme.serve.serve')) do
          Themekit.serve(@ctx, env: options.flags[:env])
        end
      end

      def self.help
        ShopifyCli::Context.message('theme.serve.help', ShopifyCli::TOOL_NAME)
      end
    end
  end
end
