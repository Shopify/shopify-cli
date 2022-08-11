module ShopifyCLI
  module Core
    ##
    # ShopifyCLI::CLI checks that the CLI in use is correct for the project.
    #
    class CliVersion
      class << self
        def using_3_0?
          !!cli_3_0_toml
        end

        private

        def cli_3_0_toml
          Utilities.directory("shopify.app.toml", Dir.pwd)
        end
      end
    end
  end
end
