# frozen_string_literal: true

require "test_helper"

describe ShopifyCli::ScriptModule::Domain::DeployPackage do
  let(:extension_point_type) { "discount" }
  let(:extension_point_schema) { "discount" }
  let(:extension_point) do
    ShopifyCli::ScriptModule::Domain::ExtensionPoint.new(
      extension_point_type, extension_point_schema, "types", "example"
    )
  end
  let(:script_name) { "foo_script" }
  let(:script) do
    ShopifyCli::ScriptModule::Domain::Script.new(script_name, extension_point, "ts", extension_point_schema)
  end

  let(:shop_id) { 1 }
  let(:config_value) { "{}" }
  let(:script_content) { "(module)" }
  let(:content_type) { "wasm" }
  let(:deploy_package) do
    ShopifyCli::ScriptModule::Domain::DeployPackage.new(
      id, script, script_content, content_type, extension_point_schema
    )
  end
  let(:script_service) { Minitest::Mock.new }
  let(:id) { "deploy_package_id" }

  describe ".new" do
    subject { deploy_package }

    it "should construct new DeployPackage" do
      assert_equal id, subject.id
      assert_equal script_content, subject.script_content
    end
  end

  describe ".deploy" do
    subject { deploy_package.deploy(script_service, shop_id, config_value) }

    it "should open write to build file and deploy" do
      FakeFS.with_fresh do
        script_service.expect(:deploy, nil) do |**kwargs|
          kwargs[:extension_point_type] == extension_point_type &&
          kwargs[:script_name] == script_name &&
          kwargs[:script_content] == script_content &&
          kwargs[:content_type] == content_type &&
          kwargs[:schema] == extension_point_schema &&
          kwargs[:shop_id] == shop_id &&
          kwargs[:config_value] == "{}"
        end
        subject
      end
    end
  end
end
