# frozen_string_literal: true

require 'project_types/script/test_helper'

describe Script::Layers::Infrastructure::AssemblyScriptTaskRunner do
  let(:ctx) { TestHelpers::FakeContext.new }
  let(:script_id) { 'id' }
  let(:script_name) { "foo" }
  let(:extension_point_config) do
    {
      "assemblyscript" => {
        "package": "@shopify/extension-point-as-fake",
        "version": "*",
        "sdk-version": "*",
      },
    }
  end
  let(:extension_point_type) { "discount" }
  let(:language) { "ts" }
  let(:as_task_runner) { Script::Layers::Infrastructure::AssemblyScriptTaskRunner.new(ctx) }
  let(:script_project) do
    TestHelpers::FakeScriptProject
      .new(language: language, extension_point_type: extension_point_type, script_name: script_name)
  end

  before do
    Script::ScriptProject.stubs(:current).returns(script_project)
  end

  describe ".build" do
    subject { as_task_runner.build }

    it "should trigger the compilation process" do
      File.expects(:read).with("#{script_name}.wasm")

      ctx
        .expects(:capture2e)
        .at_most(1)
        .returns(['output', mock(success?: true)])

      subject
    end

    it "should raise error without command output on failure" do
      output = 'error_output'
      ctx
        .stubs(:capture2e)
        .returns([output, mock(success?: false)])

      assert_raises(Script::Layers::Domain::Errors::ServiceFailureError, output) do
        subject
      end
    end
  end

  describe ".dependencies_installed?" do
    subject { as_task_runner.dependencies_installed? }

    it "should return true if node_modules folder exists" do
      FileUtils.mkdir_p("node_modules")
      assert_equal true, subject
    end

    it "should return false if node_modules folder does not exists" do
      Dir.stubs(:exist?).returns(false)
      assert_equal false, subject
    end
  end

  describe ".install_dependencies" do
    subject { as_task_runner.install_dependencies }

    it "should install using npm" do
      ctx.expects(:capture2e)
        .with("node", "--version")
        .returns(["v12.16.1", mock(success?: true)])
      ctx.expects(:capture2e)
        .with("npm", "install", "--no-audit", "--no-optional", "--loglevel error")
        .returns([nil, mock(success?: true)])
      subject
    end

    it "should raise error on failure" do
      msg = 'error message'
      ctx.expects(:capture2e).returns([msg, mock(success?: false)])
      assert_raises Script::Layers::Infrastructure::Errors::DependencyInstallError, msg do
        subject
      end
    end
  end
end
