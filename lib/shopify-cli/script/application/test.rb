# frozen_string_literal: true

require "shopify_cli"

module ShopifyCli
  module ScriptModule
    module Application
      class Test
        def self.call(ctx, language, extension_point_type, script_name)
          test_suite = Infrastructure::TestSuiteRepository.new
            .get_test_suite(language, extension_point_type, script_name)

          Infrastructure::TestSuiteRepository.new.with_test_suite_context(test_suite) do
            Infrastructure::TypeScriptWasmTestRunner.new(ctx: ctx).run_tests
          end
        end
      end
    end
  end
end
