module ShopifyCLI
  module Commands
    class App
      class Create
        class Node < ShopifyCLI::Command::AppSubCommand
          def call(*)
            puts "node"
          end
        end
      end
    end
  end
end