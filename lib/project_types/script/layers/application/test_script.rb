# frozen_string_literal: true

module Script
  module Layers
    module Application
      class TestScript
        RUNNING_MSG = "Running tests"

        class << self
          def call(ctx:, language:, extension_point_type:, script_name:)
            extension_point = ExtensionPoints.get(type: extension_point_type)
            ProjectDependencies
              .install(ctx: ctx, language: language, extension_point: extension_point, script_name: script_name)

            CLI::UI::Frame.open(RUNNING_MSG) do
              run_tests(ctx, language, extension_point_type, script_name)
            end
          end

          private

          def run_tests(ctx, language, extension_point_type, script_name)
            ensure_valid_test_suite(language, extension_point_type, script_name)

            raise TestError unless Infrastructure::TestSuiteRepository.new.with_test_suite_context do
              Infrastructure::AssemblyScriptTestRunner.new(ctx: ctx).run_tests
            end
          end

          def ensure_valid_test_suite(language, extension_point_type, script_name)
            Infrastructure::TestSuiteRepository.new.get_test_suite(language, extension_point_type, script_name)
          end
        end
      end
    end
  end
end
