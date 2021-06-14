# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::Languages::ProjectCreator do
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
      Script::Layers::Infrastructure::Languages::ProjectCreator
        .for(@context, language, extension_point, script_name, "/path")
    end

    describe "when the script language does match an entry in the registry" do
      let(:language) { "assemblyscript" }

      it "should return the entry from the registry" do
        assert_instance_of(Script::Layers::Infrastructure::Languages::AssemblyScriptProjectCreator, subject)
      end
    end

    describe "when the script language doesn't match an entry in the registry" do
      let(:language) { "ArnoldC" }

      it "should raise dependency not supported error" do
        assert_raises(Script::Layers::Infrastructure::Errors::ProjectCreatorNotFoundError) { subject }
      end
    end
  end
end
