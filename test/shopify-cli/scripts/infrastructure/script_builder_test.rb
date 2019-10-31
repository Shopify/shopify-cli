# frozen_string_literal: true

require "test_helper"

describe ShopifyCli::ScriptModule::Infrastructure::ScriptBuilder do
  describe "build" do
    subject { ShopifyCli::ScriptModule::Infrastructure::ScriptBuilder.for(script) }

    describe "when the script language and compile type match an entry in the registry" do
      let(:script) { OpenStruct.new(language: "ts") }

      it "should return the entry from the registry" do
        ShopifyCli::ScriptModule::Infrastructure::TypeScriptWasmBuilder.expects(:new).with(script)
        subject
      end
    end

    describe "when the script language and compile type doesn't match an entry in the registry" do
      let(:script) { OpenStruct.new(language: "imaginary") }

      it "should raise a builder not found error" do
        assert_raises(ShopifyCli::ScriptModule::Infrastructure::BuilderNotFoundError) { subject }
      end
    end
  end
end
