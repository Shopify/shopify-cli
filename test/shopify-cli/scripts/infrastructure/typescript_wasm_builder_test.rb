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
  let(:script) { ShopifyCli::ScriptModule::Domain::Script.new(script_name, extension_point, configuration, language, schema) }
  let(:assembly_index) do
    "export function shopify_runtime_allocate(size: u32): ArrayBuffer { return new ArrayBuffer(size); }
import { run } from \"./#{script_name}\"
export { run };"
  end
  let(:tsconfig) do
    "{
  \"extends\": \"./node_modules/assemblyscript/std/assembly.json\",
}"
  end

  subject { ShopifyCli::ScriptModule::Infrastructure::TypeScriptWasmBuilder.new(script) }

  describe "build" do
    it "should write the entry and tsconfig files, install assembly script and trigger the compilation process" do
      subject.expects(:open).with("#{script_name}.ts", "a")
      FileUtils.expects(:cp)
      File.expects(:write).with("tsconfig.json", tsconfig)
      File.expects(:write).with("package.json", "{}")
      File.expects(:read).with("schema")
      File.expects(:read).with("build/#{script_name}.wasm")

      ShopifyCli::ScriptModule::Infrastructure::TypeScriptWasmBuilder
        .any_instance
        .expects(:system)
        .at_most(2)
        .returns(true)

      subject.build
    end
  end
end
