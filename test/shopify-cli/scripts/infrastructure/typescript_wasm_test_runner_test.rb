require "test_helper"

describe ShopifyCli::ScriptModule::Infrastructure::TypeScriptWasmTestRunner do
  let(:ctx) { TestHelpers::FakeContext.new }
  let(:typescript_wasm_test_runner) { ShopifyCli::ScriptModule::Infrastructure::TypeScriptWasmTestRunner.new(ctx: ctx) }
  let(:npm_test_command) { "npm test" }

  describe ".run_tests" do
    subject { typescript_wasm_test_runner.run_tests }

    it "should execute the test script defined in package.json" do
      ctx.expects(:system).with do |arg|
        arg.eql?(npm_test_command)
      end.returns(true)

      subject
    end
  end
end
