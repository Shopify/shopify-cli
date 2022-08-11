module ShopifyCLI
  module Core
    ##
    # ShopifyCLI::Core::CliVersion checks that the CLI in use is correct for the project.
    #
    class CliVersion
      class << self
        def using_3_0?
          !!cli_3_0_toml_dir
        end

        private

        def cli_3_0_toml_dir
          Utilities.directory("shopify.app.toml", Dir.pwd)
        end
      end
    end
  end
end
