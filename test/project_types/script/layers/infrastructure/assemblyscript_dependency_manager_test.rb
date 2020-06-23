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

  describe ".installed?" do
    subject { as_dep_manager.installed? }

    it "should return true if node_modules folder exists" do
      FileUtils.mkdir_p("node_modules")
      assert_equal true, subject
    end

    it "should return false if node_modules folder does not exists" do
      assert_equal false, subject
    end
  end

  describe ".install" do
    subject { as_dep_manager.install }

    it "should install using npm" do
      @context.expects(:capture2e)
        .with("node", "--version")
        .returns(["v12.16.1", mock(success?: true)])
      @context.expects(:capture2e)
        .with("npm", "install", "--no-audit", "--no-optional", "--loglevel error")
        .returns([nil, mock(success?: true)])
      subject
    end

    it "should raise error on failure" do
      msg = 'error message'
      @context.expects(:capture2e).returns([msg, mock(success?: false)])
      assert_raises Script::Layers::Infrastructure::Errors::DependencyInstallError, msg do
        subject
      end
    end
  end
end
