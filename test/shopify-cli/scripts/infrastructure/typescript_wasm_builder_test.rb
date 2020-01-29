# frozen_string_literal: true

require "test_helper"
require "tmpdir"

describe ShopifyCli::ScriptModule::Infrastructure::TypeScriptWasmBuilder do
  let(:script_name) { "foo" }
  let(:schema) { "schema" }
  let(:extension_point) { ShopifyCli::ScriptModule::Domain::ExtensionPoint.new("discount", schema, "types", "example") }
  let(:language) { "ts" }
  let(:script) { ShopifyCli::ScriptModule::Domain::Script.new(script_name, extension_point, language) }
  let(:allocate_func) do
    "export function shopify_runtime_allocate(size: u32): ArrayBuffer { return new ArrayBuffer(size); }"
  end
  let(:tsconfig) do
    "{
  \"extends\": \"./node_modules/assemblyscript/std/assembly.json\",
}"
  end

  subject { ShopifyCli::ScriptModule::Infrastructure::TypeScriptWasmBuilder.new(script) }

  describe ".build" do
    it "should write the entry and tsconfig files and trigger the compilation process" do
      File.expects(:open).with("#{script_name}.ts", "a")
      File.expects(:write).with("tsconfig.json", tsconfig)
      FileUtils.expects(:cp)
      File.expects(:read).with("schema")
      File.expects(:read).with("build/#{script_name}.wasm")

      ShopifyCli::ScriptModule::Infrastructure::TypeScriptWasmBuilder
        .any_instance
        .expects(:system)
        .at_most(1)
        .returns(true)

      subject.build
    end
  end
end
