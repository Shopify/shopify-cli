require "test_helper"

describe ShopifyCli::ScriptModule::Infrastructure::TypeScriptWasmTestRunner do
  let(:typescript_wasm_test_runner) { ShopifyCli::ScriptModule::Infrastructure::TypeScriptWasmTestRunner.new }
  let(:asm_script_source) { "git://github.com/AssemblyScript/assemblyscript#3b227d47b1c546ddd0ae19fbd49bdae9ad5c1c99" }
  let(:install_cmd) { "npm install @as-pect/cli @as-pect/core @as-pect/assembly #{asm_script_source} > /dev/null 2>&1" }
  let(:execute_cmd) { "npx asp --config " }

  describe ".run_tests" do
    subject { typescript_wasm_test_runner.run_tests }

    it "should execute tests with as-pect" do
      typescript_wasm_test_runner.expects(:system).with do |arg|
        arg.include?(execute_cmd)
      end.returns(true)

      typescript_wasm_test_runner.expects(:system).with do |arg|
        arg.eql?(install_cmd)
      end.returns(true)

      FakeFS.with_fresh do
        subject
      end
    end

    it "should raise ServiceFailureError if install fails" do
      typescript_wasm_test_runner.expects(:system).with do |arg|
        arg.include?(execute_cmd)
      end.never

      typescript_wasm_test_runner.expects(:system).with do |arg|
        arg.eql?(install_cmd)
      end.returns(false)

      FakeFS.with_fresh do
        assert_raises(ShopifyCli::ScriptModule::Domain::ServiceFailureError) { subject }
      end
    end

    it "should raise ServiceFailureError if execute fails" do
      typescript_wasm_test_runner.expects(:system).with do |arg|
        arg.include?(execute_cmd)
      end.returns(false)

      typescript_wasm_test_runner.expects(:system).with do |arg|
        arg.eql?(install_cmd)
      end.returns(true)

      FakeFS.with_fresh do
        assert_raises(ShopifyCli::ScriptModule::Domain::ServiceFailureError) { subject }
      end
    end
  end
end
