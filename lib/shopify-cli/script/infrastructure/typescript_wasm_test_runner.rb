# frozen_string_literal: true
module ShopifyCli
  module ScriptModule
    module Infrastructure
      class TypeScriptWasmTestRunner
        def run_tests
          install_test_runner
          Dir.mktmpdir do |temp_dir|
            prepare_config_file(temp_dir)
            execute_tests(temp_dir)
          end
        end

        private

        ASM_SCRIPT_SOURCE = "git://github.com/AssemblyScript/assemblyscript#3b227d47b1c546ddd0ae19fbd49bdae9ad5c1c99"
        INSTALL_AS_PECT = "npm install @as-pect/cli @as-pect/core @as-pect/assembly #{ASM_SCRIPT_SOURCE} > /dev/null 2>&1"

        CONFIG_FILE = "%{temp_dir}/as-pect.config.js"
        CONFIG_FILE_CONTENT = "module.exports = {
          include: [\"**/*.spec.ts\"],
          add: [\"**/*.include.ts\"],
          flags: {
            // \"--textFile\": [\"output.wat\"],
            \"--runtime\": [\"stub\"]
          },
          disclude: [/node_modules/],
          imports: {},
          performance: {
            enabled: false,
            maxSamples: 10000,
            maxTestRunTime: 5000,
            reportMedian: true,
            reportAverage: true,
            reportStandardDeviation: false,
            reportMax: false,
            reportMin: false,
          },
          outputBinary: false,
        };
        "

        RUN_AS_PECT_COMMAND = "npx asp --config #{CONFIG_FILE}"

        private_constant :ASM_SCRIPT_SOURCE, :INSTALL_AS_PECT, :CONFIG_FILE, :CONFIG_FILE_CONTENT, :RUN_AS_PECT_COMMAND

        def prepare_config_file(temp_dir)
          File.write(format(CONFIG_FILE, temp_dir: temp_dir), CONFIG_FILE_CONTENT)
        end

        def install_test_runner
          install_success = system(INSTALL_AS_PECT)
          raise Domain::ServiceFailureError unless install_success
        end

        def execute_tests(temp_dir)
          execute_success = system(format(RUN_AS_PECT_COMMAND, temp_dir: temp_dir))
          raise Domain::ServiceFailureError unless execute_success
        end
      end
    end
  end
end
