# frozen_string_literal: true

module ShopifyCLI
  module Theme
    class Syncer
      class Uploader
        module Forms
          class BaseStrategyForm < ShopifyCLI::Form
            attr_accessor :strategy

            def ask
              ctx.puts(title_context(file))

              self.strategy = CLI::UI::Prompt.ask(title_question, allow_empty: false) do |handler|
                strategies.each do |strategy|
                  handler.option(as_text(strategy)) { strategy }
                end
              end

              exit_cli if self.strategy == :exit

              self
            end

            protected

            ##
            # List of strategies that populate the form options
            #
            def strategies
              raise "`#{self.class.name}#strategies' must be defined"
            end

            ##
            # Message prefix for the form title and options (strategies).
            # See the methods `title` and `as_text`
            #
            def prefix
              raise "`#{self.class.name}#prefix' must be defined"
            end

            private

            def exit_cli
              exit(0)
            end

            def title_context(file)
              ctx.message("#{prefix}.title_context", file.relative_path)
            end

            def title_question
              ctx.message("#{prefix}.title_question")
            end

            def as_text(strategy)
              ctx.message("#{prefix}.#{strategy}")
            end
          end
        end
      end
    end
  end
end
