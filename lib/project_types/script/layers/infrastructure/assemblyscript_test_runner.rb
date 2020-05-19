# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class AssemblyScriptTestRunner
        include SmartProperties
        property! :ctx, accepts: ShopifyCli::Context

        RUN_TEST_COMMAND = "npm test"

        def run_tests
          ctx.setenv("FORCE_COLOR", "1") # force aspect output to have colour
          ctx.system(RUN_TEST_COMMAND)
        end
      end
    end
  end
end
