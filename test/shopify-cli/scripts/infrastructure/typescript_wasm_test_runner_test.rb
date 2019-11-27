require "test_helper"

describe ShopifyCli::ScriptModule::Infrastructure::TypeScriptWasmTestRunner do
  let(:typescript_wasm_test_runner) { ShopifyCli::ScriptModule::Infrastructure::TypeScriptWasmTestRunner.new }
  let(:install_cmd) do
    "npm install @as-pect/cli@2.6.0 @as-pect/core@2.6.0 @as-pect/assembly@2.6.0 assemblyscript@0.8.0 > /dev/null 2>&1"
  end
  let(:execute_cmd) { "npx asp" }

  describe ".run_tests" do
    subject { typescript_wasm_test_runner.run_tests }

    it "should execute tests with as-pect" do
      CLI::Kit::System.expects(:system).with do |arg|
        arg.eql?(execute_cmd)
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
  end
end
