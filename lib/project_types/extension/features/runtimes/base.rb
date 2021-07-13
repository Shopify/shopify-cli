module Extension
  module Features
    module Runtimes
      class Base
        def available_flags
          []
        end

        def supports?(flag)
          available_flags.include?(flag)
        end

        def active_runtime?(cli_package, identifier)
          raise NotImplementedError
        end
      end
    end
  end
end
