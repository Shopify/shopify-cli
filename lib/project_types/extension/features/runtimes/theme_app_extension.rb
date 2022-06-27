module Extension
  module Features
    module Runtimes
      class ThemeAppExtension < Base
        IDENTIFIERS = [
          "THEME_APP_EXTENSION"
        ]

        def available_flags
          []
        end

        def supports?(flag)
          available_flags.include?(flag)
        end

        def active_runtime?(cli_package, identifier)
          IDENTIFIERS.include?(identifier)
        end
      end
    end
  end
end
