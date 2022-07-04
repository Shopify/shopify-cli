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
          curr = Dir.pwd
          loop do
            return nil if curr == "/" || /^[A-Z]:\/$/.match?(curr)
            file = File.join(curr, "shopify.app.toml")
            return curr if File.exist?(file)
            curr = File.dirname(curr)
          end
        end
      end
    end
  end
end
