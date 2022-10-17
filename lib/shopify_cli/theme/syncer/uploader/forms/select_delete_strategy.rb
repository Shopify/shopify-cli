# frozen_string_literal: true

require_relative "base_strategy_form"

module ShopifyCLI
  module Theme
    class Syncer
      class Uploader
        module Forms
          class SelectDeleteStrategy < BaseStrategyForm
            flag_arguments :file

            def strategies
              %i[
                delete
                restore
                exit
              ]
            end

            def prefix
              "theme.serve.syncer.forms.delete_strategy"
            end
          end
        end
      end
    end
  end
end
