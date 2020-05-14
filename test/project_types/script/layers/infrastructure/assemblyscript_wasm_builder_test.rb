# frozen_string_literal: true

require 'project_types/script/test_helper'

describe Script::Layers::Infrastructure::AssemblyScriptWasmBuilder do
  let(:script_id) { 'id' }
  let(:script_name) { "foo" }
  let(:schema) { "schema" }
  let(:extension_point_config) do
    {
      "assemblyscript" => {
        "package": "@shopify/extension-point-as-fake",
        "version": "*",
        "sdk-version": "*",
      },
    }
  end
  let(:extension_point) { Script::Layers::Domain::ExtensionPoint.new("discount", extension_point_config) }
  let(:language) { "ts" }
  let(:script) { Script::Layers::Domain::Script.new(script_id, script_name, extension_point, language) }

  subject { Script::Layers::Infrastructure::AssemblyScriptWasmBuilder.new(script) }

  describe ".build" do
    it "should trigger the compilation process" do
      File.expects(:read).with("schema")
      File.expects(:read).with("#{script_name}.wasm")

      CLI::Kit::System
        .expects(:capture2e)
        .at_most(1)
        .returns(['output', mock(success?: true)])

      subject.build
    end

    it "should raise error without command output on failure" do
      output = 'error_output'
      CLI::Kit::System
        .stubs(:capture2e)
        .returns([output, mock(success?: false)])

      assert_raises(Script::Layers::Domain::Errors::ServiceFailureError, output) do
        subject.build
      end
    end
  end
end
