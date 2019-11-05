# frozen_string_literal: true

require "test_helper"
require "tmpdir"

describe ShopifyCli::ScriptModule::Infrastructure::TypeScriptWasmBuilder do
  let(:script_name) { "foo" }
  let(:schema) { "schema" }
  let(:extension_point) { ShopifyCli::ScriptModule::Domain::ExtensionPoint.new("discount", schema, "types", "example") }
  let(:script_root) { "#{ShopifyCli::ScriptModule::Infrastructure::Repository::INSTALLATION_BASE_PATH}/#{extension_point.type}/#{script_name}" }
  let(:language) { "ts" }
  let(:configuration) { MiniTest::Mock.new }
  let(:script) { ShopifyCli::ScriptModule::Domain::Script.new(script_name, extension_point, language, schema) }

  subject { ShopifyCli::ScriptModule::Infrastructure::NoopBuilder.new(script) }

  describe "build" do
    it "should read the source file" do
      File.expects(:read).with(File.basename(script.id))

      subject.build
    end
  end
end
