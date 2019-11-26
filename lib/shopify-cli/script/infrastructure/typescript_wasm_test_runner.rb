# frozen_string_literal: true
module ShopifyCli
  module ScriptModule
    module Infrastructure
      class TypeScriptWasmTestRunner
        def run_tests
          install_test_runner
          execute_tests
        end

        private

        INSTALL_AS_PECT = "npm install @as-pect/cli@2.6.0 @as-pect/core@2.6.0 @as-pect/assembly@2.6.0 "\
          "assemblyscript@0.8.0 > /dev/null 2>&1"
        RUN_AS_PECT_COMMAND = "npx asp"

        private_constant :INSTALL_AS_PECT, :RUN_AS_PECT_COMMAND

        def install_test_runner
          install_success = system(INSTALL_AS_PECT)
          raise Domain::ServiceFailureError unless install_success
        end

        def execute_tests
          system(RUN_AS_PECT_COMMAND)
        end
      end
    end
  end
end
