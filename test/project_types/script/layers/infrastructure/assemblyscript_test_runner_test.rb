# frozen_string_literal: true

require 'project_types/script/test_helper'

describe Script::Layers::Infrastructure::AssemblyScriptTestRunner do
  let(:ctx) { TestHelpers::FakeContext.new }
  let(:assemblyscript_wasm_test_runner) do
    Script::Layers::Infrastructure::AssemblyScriptTestRunner.new(ctx: ctx)
  end
  let(:npm_test_command) { "npm test" }

  describe ".run_tests" do
    subject { assemblyscript_wasm_test_runner.run_tests }

    it "should execute the test script defined in package.json" do
      ctx.expects(:system).with(npm_test_command).returns(true)
      subject
    end
  end
end
