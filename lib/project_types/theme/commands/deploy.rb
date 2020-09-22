# frozen_string_literal: true
module Theme
  module Commands
    class Deploy < ShopifyCli::Command
      def call(*)
        CLI::UI::Frame.open(@ctx.message('theme.checking_themekit')) do
          Themekit.ensure_themekit_installed(@ctx)
        end

        CLI::UI::Frame.open(@ctx.message('theme.deploy.deploying')) do
          unless CLI::UI::Prompt.confirm(@ctx.message('theme.deploy.confirmation'))
            @ctx.abort(@ctx.message('theme.deploy.abort'))
          end

          unless Themekit.deploy(@ctx)
            @ctx.abort(@ctx.message('theme.deploy.error'))
          end
        end

        @ctx.done(@ctx.message('theme.deploy.info.deployed'))
      end
    end
  end
end
