require 'shopify_cli'

module ShopifyCli
  module Commands
    class Deploy
      class Now < ShopifyCli::Task

        def self.help
          <<~HELP
            Deploy the current app project to Zeit Now
            Usage: {{command:#{ShopifyCli::TOOL_NAME} deploy now}}
          HELP
        end

        def call(ctx, _name = nil)
          @ctx = ctx

          if (now_installed?)
            now_deploy
          else 
            now_install
            now_deploy
          end
        end

        private
        
        def now_installed?
          _output, status = @ctx.capture2e('now --version')
          status.success?
        rescue
          false
        end      
        
        def now_install
          return if now_installed?
          
          CLI::UI::Frame.open("Installing Now CLI with npm", success_text: '{{v}} Now installed') do
            result = @ctx.system('npm i -g now')
            raise(ShopifyCli::Abort, "Could not install Now CLI") unless result.success?
          end
        end
        
        def now_deploy
          CLI::UI::Frame.open("Deploying to Now", success_text: '{{v}} Successfully deployed to Now') do
            result = @ctx.system('now')
            raise(ShopifyCli::Abort, "Could not deploy to Now") unless result.success?
          end
        end
        
      end
    end
  end
end
