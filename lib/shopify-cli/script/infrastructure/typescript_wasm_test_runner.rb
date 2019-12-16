# frozen_string_literal: true
module ShopifyCli
  module ScriptModule
    module Infrastructure
      class TypeScriptWasmTestRunner
        include SmartProperties

        property! :ctx, accepts: ShopifyCli::Context

        def run_tests
          ctx.system(RUN_TEST_COMMAND)
        end

        RUN_TEST_COMMAND = "npm test"

        private_constant :RUN_TEST_COMMAND
      end
    end
  end
end
