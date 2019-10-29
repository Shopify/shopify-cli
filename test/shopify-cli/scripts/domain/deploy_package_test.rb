# frozen_string_literal: true

require "test_helper"

describe ShopifyCli::ScriptModule::Domain::DeployPackage do
  let(:extension_point_type) { "discount" }
  let(:extension_point_schema) { "discount" }
  let(:extension_point) { ShopifyCli::ScriptModule::Domain::ExtensionPoint.new(extension_point_type, extension_point_schema, "types", "example") }
  let(:configuration_schema) do
    <<~GRAPHQL
      input Configuration {
        _: Boolean
      }

      type Query {
        configuration: Configuration
      }
    GRAPHQL
  end

  let(:configuration) do
    ShopifyCli::ScriptModule::Domain::Configuration.new("config_id", configuration_schema, configuration_schema, "code")
  end
  let(:script_name) { "foo_script" }
  let(:script) { ShopifyCli::ScriptModule::Domain::Script.new(script_name, extension_point, configuration, "ts", extension_point_schema) }
  let(:shop_id) { 1 }
  let(:config_value) { "{}" }
  let(:bytecode) { "(module)" }
  let(:deploy_package) { ShopifyCli::ScriptModule::Domain::DeployPackage.new(id, script, bytecode) }
  let(:script_service) { Minitest::Mock.new }
  let(:id) { "deploy_package_id" }

  describe ".new" do
    subject { deploy_package }

    it "should construct new WasmBlob" do
      assert_equal id, subject.id
      assert_equal bytecode, subject.bytecode
    end
  end

  describe ".deploy" do
    subject { deploy_package.deploy(script_service, shop_id, config_value) }

    it "should open write to build.wasm and deploy" do
      FakeFS.with_fresh do
        script_service.expect(:deploy, nil) do |**kwargs|
          kwargs[:extension_point_type] == extension_point_type &&
          kwargs[:extension_point_schema] == extension_point_schema &&
          kwargs[:script_name] == script_name &&
          kwargs[:bytecode] == bytecode &&
          kwargs[:config_schema] == configuration_schema &&
          kwargs[:shop_id] == shop_id &&
          kwargs[:config_value] == "{}"
        end
        subject
      end
    end
  end
end
