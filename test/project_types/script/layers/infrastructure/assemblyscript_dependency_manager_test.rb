# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::AssemblyScriptDependencyManager do
  include TestHelpers::FakeFS

  let(:script_name) { "foo_discount_script" }
  let(:language) { "ts" }
  let(:extension_point_config) do
    {
      "assemblyscript" => {
        "package": "@shopify/extension-point-as-fake",
        "version": "*",
        "sdk-version": "*",
        "toolchain-version": "*",
      },
    }
  end
  let(:extension_point) { Script::Layers::Domain::ExtensionPoint.new("discount", extension_point_config) }
  let(:as_dep_manager) do
    Script::Layers::Infrastructure::AssemblyScriptDependencyManager
      .new(@context, language, extension_point, script_name)
  end

  describe ".bootstrap" do
    subject { as_dep_manager.bootstrap }

    it "should write to npmrc" do
      @context
        .expects(:system)
        .with('npm', '--userconfig', './.npmrc', 'config', 'set', '@shopify:registry', 'https://registry.npmjs.com')
      subject
    end

    it "should write to package.json" do
      @context.expects(:system)
      subject
      assert File.exist?("package.json")
    end
  end
end
