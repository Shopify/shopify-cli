# frozen_string_literal: true

require "test_helper"

describe ShopifyCli::ScriptModule::Infrastructure::DependencyManager do
  describe ".for" do
    let(:script_name) { "foo_discount" }
    let(:ctx) { TestHelpers::FakeContext.new }
    subject { ShopifyCli::ScriptModule::Infrastructure::DependencyManager.for(ctx, script_name, language) }

    describe "when the script language does match an entry in the registry" do
      let(:language) { "ts" }

      it "should return the entry from the registry" do
        assert_instance_of(ShopifyCli::ScriptModule::Infrastructure::TypeScriptDependencyManager, subject)
      end
    end

    describe "when the script language doesn't match an entry in the registry" do
      let(:language) { "ArnoldC" }

      it "should raise dependency not supported error" do
        assert_raises(ShopifyCli::Abort, "{{x}} No dependency support for #{language}") { subject }
      end
    end
  end
end
