module ShopifyCLI
  module Commands
    class App
      class Create
        class Rails < ShopifyCLI::Command::AppSubCommand
          def call(*)
            puts "rails"
          end
        end
      end
    end
  end
end