# frozen_string_literal: true

module ShopifyCLI
  module Theme
    class DevServer
      class ReloadMode
        MODES = [:"hot-reload", :"full-page", :off]

        class << self
          def default
            :"hot-reload"
          end

          def get!(mode)
            MODES.find { |m| m == mode.to_sym } || raise_error(mode)
          end

          private

          def raise_error(invalid_mode)
            error_message = ShopifyCLI::Context.message("theme.serve.reload_mode_is_not_valid", invalid_mode)
            help_message = ShopifyCLI::Context.message("theme.serve.try_a_valid_reload_mode", valid_modes)

            ShopifyCLI::Context.abort(error_message, help_message)
          end

          def valid_modes
            MODES.map { |v| "`#{v}`" }.join(", ")
          end
        end
      end
    end
  end
end
