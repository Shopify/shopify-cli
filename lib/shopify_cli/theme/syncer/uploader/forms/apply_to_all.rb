# frozen_string_literal: true

require_relative "apply_to_all_form"

module ShopifyCLI
  module Theme
    class Syncer
      class Uploader
        module Forms
          class ApplyToAll
            attr_reader :value

            def initialize(ctx, number_of_files)
              @ctx = ctx
              @number_of_files = number_of_files
              @value = nil
              @apply = nil
            end

            def apply?(value)
              return unless @number_of_files > 1

              if @apply.nil?
                @apply = ask.apply?
                @value = value if @apply
              end

              @apply
            end

            private

            def ask
              ApplyToAllForm.ask(@ctx, [], number_of_files: @number_of_files)
            end
          end
        end
      end
    end
  end
end
