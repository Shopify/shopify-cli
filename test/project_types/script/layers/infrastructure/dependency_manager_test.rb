# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::DependencyManager do
  describe ".for" do
    let(:script_name) { "foo_discount" }
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
    subject do
      Script::Layers::Infrastructure::DependencyManager.for(
        @context,
        language,
        extension_point,
        script_name
      )
    end

    describe "when the script language does match an entry in the registry" do
      let(:language) { "ts" }

      it "should return the entry from the registry" do
        assert_instance_of(Script::Layers::Infrastructure::AssemblyScriptDependencyManager, subject)
      end
    end

    describe "when the script language doesn't match an entry in the registry" do
      let(:language) { "ArnoldC" }

      it "should raise dependency not supported error" do
        assert_raises(
          Script::Layers::Infrastructure::DependencyError,
          "{{x}} No dependency support for #{language}"
        ) { subject }
      end
    end
  end
end
