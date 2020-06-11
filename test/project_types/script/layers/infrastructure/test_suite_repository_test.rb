# frozen_string_literal: true

require "project_types/script/test_helper"
require_relative "fake_script_repository"

describe Script::Layers::Infrastructure::TestSuiteRepository do
  include TestHelpers::FakeFS

  let(:extension_point_type) { "discount" }
  let(:extension_point_config) do
    {
      "assemblyscript" => {
        "package": "@shopify/extension-point-as-fake",
        "version": "*",
        "sdk-version": "*",
      },
    }
  end
  let(:extension_point) { Script::Layers::Domain::ExtensionPoint.new(extension_point_type, extension_point_config) }
  let(:script_name) { "myscript" }
  let(:language) { "ts" }
  let(:script_id) { 'id' }
  let(:script) { Script::Layers::Domain::Script.new(script_id, script_name, extension_point, language) }
  let(:template_base) { Script::Project.project_filepath('templates') }
  let(:config_file) { "#{template_base}/ts/as-pect.config.js" }
  let(:spec_test_base) { "#{script_name}/test" }
  let(:relative_path_to_node_modules) { "." }
  let(:relative_path_to_src) { "../src" }
  let(:aspect_dts_file) { "#{spec_test_base}/as-pect.d.ts" }
  let(:aspect_dts_file_contents) { "/// <reference types=\"@as-pect/assembly/types/as-pect\" />" }
  let(:script_repository) { Script::Layers::Infrastructure::FakeScriptRepository.new }
  let(:repository) { Script::Layers::Infrastructure::TestSuiteRepository.new }
  let(:project) { TestHelpers::FakeProject.new }

  before do
    Script::Layers::Infrastructure::ScriptRepository.stubs(:new).returns(script_repository)
    Script::ScriptProject.stubs(:current).returns(project)
    project.directory = script_name
  end

  describe ".create_test_suite" do
    subject { repository.create_test_suite(script) }

    it "should create a test suite" do
      FakeFS::FileSystem.clone(config_file)
      CLI::Kit::System.expects(:capture2e)
        .with("npx --no-install shopify-scripts-bootstrap test myscript/test")
        .returns(["", OpenStruct.new(success?: true)])

      repository.stubs(:relative_path_to_source_dir).returns(relative_path_to_src)

      tsconfig_stub = stub("tsconfig")
      tsconfig_stub
        .expects(:with_extends_assemblyscript_config)
        .with(relative_path_to_node_modules: relative_path_to_node_modules)
        .returns(tsconfig_stub)
      tsconfig_stub
        .expects(:with_module_resolution_paths)
        .with(paths: { "*": ["#{relative_path_to_src}/*.ts"] })
        .returns(tsconfig_stub)
      tsconfig_stub.expects(:write)
      Script::Layers::Infrastructure::AssemblyScriptTsConfig.stubs(:new).returns(tsconfig_stub)

      File.expects(:write).with(aspect_dts_file, aspect_dts_file_contents)

      subject
    end
  end
end
