# frozen_string_literal: true

module ShopifyCLI
  module Theme
    class Syncer
      class Uploader
        module Forms
          class ApplyToAllForm < ShopifyCLI::Form
            attr_accessor :apply
            flag_arguments :number_of_files

            def ask
              title = message("title", number_of_files - 1)

              self.apply = CLI::UI::Prompt.ask(title, allow_empty: false) do |handler|
                handler.option(message("yes")) { true }
                handler.option(message("no")) { false }
              end

              self
            end

            def apply?
              apply
            end

            private

            def message(key, *params)
              ctx.message("theme.serve.syncer.forms.apply_to_all.#{key}", *params)
            end
          end
        end
      end
    end
  end
end
