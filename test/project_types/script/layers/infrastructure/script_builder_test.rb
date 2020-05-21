# frozen_string_literal: true

require 'project_types/script/test_helper'

describe Script::Layers::Infrastructure::ScriptBuilder do
  describe "build" do
    subject { Script::Layers::Infrastructure::ScriptBuilder.for(script) }

    describe "when the script language and compile type match an entry in the registry" do
      let(:script) { OpenStruct.new(language: "ts") }

      it "should return the entry from the registry" do
        Script::Layers::Infrastructure::AssemblyScriptWasmBuilder.expects(:new).with(script)
        subject
      end
    end

    describe "when the script language and compile type doesn't match an entry in the registry" do
      let(:script) { OpenStruct.new(language: "imaginary") }

      it "should raise a builder not found error" do
        assert_raises(Script::Layers::Infrastructure::Errors::BuilderNotFoundError) { subject }
      end
    end
  end
end
