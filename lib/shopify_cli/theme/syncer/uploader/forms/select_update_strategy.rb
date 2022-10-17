# frozen_string_literal: true

require_relative "base_strategy_form"

module ShopifyCLI
  module Theme
    class Syncer
      class Uploader
        module Forms
          class SelectUpdateStrategy < BaseStrategyForm
            flag_arguments :file, :exists_remotely

            def strategies
              %i[
                keep_remote
                keep_local
                union_merge
                exit
              ]
            end

            def prefix
              "theme.serve.syncer.forms.#{exists_remotely ? "update_strategy" : "update_remote_deleted_strategy"}"
            end
          end
        end
      end
    end
  end
end
