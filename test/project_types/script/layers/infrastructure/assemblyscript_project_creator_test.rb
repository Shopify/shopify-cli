# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::AssemblyScriptProjectCreator do
  include TestHelpers::FakeFS

  let(:script_name) { "myscript" }
  let(:language) { "ts" }
  let(:script_id) { 'id' }
  let(:script) { Script::Layers::Domain::Script.new(script_id, script_name, extension_point, language) }
  let(:template_base) { Script::Project.project_filepath('templates') }
  let(:aspect_config_template_file) { "#{template_base}/ts/as-pect.config.js" }
  let(:aspect_definition_template_file) { "#{template_base}/ts/as-pect.d.ts" }
  let(:spec_test_base) { "#{script_name}/test" }
  let(:relative_path_to_node_modules) { "." }
  let(:aspect_dts_file) { "#{spec_test_base}/as-pect.d.ts" }
  let(:aspect_config_file) { "#{spec_test_base}/as-pect.config.js" }
  let(:project) { TestHelpers::FakeProject.new }
  let(:context) { TestHelpers::FakeContext.new }
  let(:extension_point_type) { "discount" }
  let(:extension_point) { Script::Layers::Domain::ExtensionPoint.new(extension_point_type, extension_point_config) }
  let(:project_creator) do
    Script::Layers::Infrastructure::AssemblyScriptProjectCreator
      .new(context, extension_point, script_name, script_name)
  end
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

  before do
    context.mkdir_p(script_name)
    Script::ScriptProject.stubs(:current).returns(project)
    project.directory = script_name
  end

  describe ".setup_dependencies" do
    subject { project_creator.setup_dependencies }

    it "should write to npmrc" do
      context
        .expects(:system)
        .with('npm', '--userconfig', './.npmrc', 'config', 'set', '@shopify:registry', 'https://registry.npmjs.com')
      context
        .expects(:system)
        .with('npm', '--userconfig', './.npmrc', 'config', 'set', 'engine-strict', 'true')
      subject
    end

    it "should write to package.json" do
      context.expects(:system).twice
      subject
      assert File.exist?("package.json")
    end
  end

  describe ".bootstrap" do
    subject { project_creator.bootstrap }

    it "should create a test suite" do
      project_creator.stubs(:create_src_folder).returns(true)
      FakeFS::FileSystem.clone(aspect_config_template_file)
      FakeFS::FileSystem.clone(aspect_definition_template_file)

      context.expects(:capture2e)
        .with("npx --no-install shopify-scripts-bootstrap test myscript/test")
        .returns(["", OpenStruct.new(success?: true)])

      expect_write_tsconfig_file("../src")

      context.expects(:cp).with(aspect_config_template_file, aspect_config_file)
      context.expects(:cp).with(aspect_definition_template_file, aspect_dts_file)

      subject
    end

    it "should create all src files" do
      project_creator.stubs(:create_test_folder).returns(true)

      context.expects(:capture2e)
        .with("npx --no-install shopify-scripts-bootstrap src myscript/src")
        .returns(["", OpenStruct.new(success?: true)])

      expect_write_tsconfig_file(".")

      subject
    end
  end

  private

  def expect_write_tsconfig_file(path_to_source)
    tsconfig_stub = stub("tsconfig")
    tsconfig_stub
      .expects(:with_extends_assemblyscript_config)
      .with(relative_path_to_node_modules: relative_path_to_node_modules)
      .returns(tsconfig_stub)
    tsconfig_stub
      .expects(:with_module_resolution_paths)
      .with(paths: { "*": ["#{path_to_source}/*.ts"] })
      .returns(tsconfig_stub)
    tsconfig_stub.expects(:write)
    Script::Layers::Infrastructure::AssemblyScriptTsConfig.stubs(:new).returns(tsconfig_stub)
  end
end
