# frozen_string_literal: true

module ShopifyCLI
  module Theme
    module DevServer
      class ReloadMode
        FULL_PAGE = :"full-page"
        FAST = :fast
        OFF = :off

        class << self
          def default
            FAST
          end

          def get(enum)
            values.find { |v| v == enum.to_sym } || raise_error(enum)
          end

          def values
            constants(false).map { |c| const_get(c) }
          end

          private

          def raise_error(enum)
            error_message = ShopifyCLI::Context.message("theme.serve.reload_mode_is_not_valid", enum)
            help_message = ShopifyCLI::Context.message("theme.serve.try_a_valid_reload_mode", valid_reload_modes)

            ShopifyCLI::Context.abort(error_message, help_message)
          end

          def valid_reload_modes
            values.map { |v| "`#{v}`" }.join(", ")
          end
        end
      end
    end
  end
end
