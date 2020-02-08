# frozen_string_literal: true

require "test_helper"

describe ShopifyCli::ScriptModule::ScriptProject do
  describe ".initialize" do
    subject { ShopifyCli::ScriptModule::ScriptProject.new(directory: "dir/") }
    let(:extension_point_type) { "discount" }
    let(:script_name) { "myscript" }

    it "should be created with correct context information when config values exist" do
      ShopifyCli::Project.any_instance
        .stubs(:config)
        .returns('extension_point_type' => extension_point_type, 'script_name' => script_name)
      script_project = subject
      assert_equal extension_point_type, script_project.extension_point_type
      assert_equal script_name, script_project.script_name
    end

    it "should raise InvalidScriptProjectContextError when config value extension_point_type is missing" do
      ShopifyCli::Project.any_instance.stubs(:config).returns('script_name' => script_name)
      assert_raises(ShopifyCli::ScriptModule::InvalidScriptProjectContextError) { subject }
    end

    it "should raise InvalidScriptProjectContextError when config value script_name is missing" do
      ShopifyCli::Project.any_instance.stubs(:config).returns('extension_point_type' => extension_point_type)
      assert_raises(ShopifyCli::ScriptModule::InvalidScriptProjectContextError) { subject }
    end
  end
end
