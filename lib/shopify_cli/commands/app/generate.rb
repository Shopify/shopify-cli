module ShopifyCLI
  module Commands
    class App
      class Generate < ShopifyCLI::Command::AppSubCommand
        def call(*)
          puts "generate"
        end

        def self.help
          ShopifyCLI::Context.message("core.app.generate.help", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
        end
      end
    end
  end
end
