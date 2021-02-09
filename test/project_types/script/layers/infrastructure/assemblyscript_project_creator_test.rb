# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::AssemblyScriptProjectCreator do
  include TestHelpers::FakeFS

  let(:script_name) { "myscript" }
  let(:language) { "AssemblyScript" }
  let(:script_id) { 'id' }
  let(:project) { TestHelpers::FakeProject.new }
  let(:context) { TestHelpers::FakeContext.new }
  let(:extension_point_type) { "discount" }
  let(:extension_point) { Script::Layers::Domain::ExtensionPoint.new(extension_point_type, extension_point_config) }
  let(:project_creator) do
    Script::Layers::Infrastructure::AssemblyScriptProjectCreator
      .new(ctx: context, extension_point: extension_point, script_name: script_name, path_to_project: script_name)
  end
  let(:extension_point_config) do
    {
      "assemblyscript" => {
        "package": "@shopify/extension-point-as-fake",
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
      assert context.file_exist?("package.json")
    end

    it "should fetch the latest extension point version" do
      context.expects(:system).twice

      context
        .expects(:capture2e)
        .with("npm show @shopify/extension-point-as-fake version --json")
        .once
        .returns([JSON.generate("2.0.0"), OpenStruct.new(success?: true)])

      sdk = mock
      sdk.expects(:sdk_version)
      sdk.expects(:toolchain_version)
      sdk.expects(:package).twice.returns("@shopify/extension-point-as-fake")
      extension_point.expects(:sdks).times(4).returns(stub(all: [sdk], assemblyscript: sdk))

      subject
      version = JSON.parse(File.read("package.json")).dig("devDependencies", "@shopify/extension-point-as-fake")
      assert_equal "^2.0.0", version
    end

    it "should raise if the latest extension point version can't be fetched" do
      context.expects(:system).twice

      context
        .expects(:capture2e)
        .with("npm show @shopify/extension-point-as-fake version --json")
        .once
        .returns([JSON.generate(""), OpenStruct.new(success?: false)])

      sdk = mock
      sdk.expects(:sdk_version)
      sdk.expects(:toolchain_version)
      sdk.expects(:package).twice.returns("@shopify/extension-point-as-fake")
      extension_point.expects(:sdks).times(4).returns(stub(all: [sdk], assemblyscript: sdk))

      assert_raises(Script::Layers::Domain::Errors::ServiceFailureError) { subject }
    end
  end

  describe ".bootstrap" do
    subject { project_creator.bootstrap }

    it "should delegate the bootstrapping process to the language toolchain" do
      context.expects(:capture2e)
        .with(
          "npx --no-install shopify-scripts-toolchain-as bootstrap --from #{extension_point.type} --dest #{script_name}"
        )
        .returns(["", OpenStruct.new(success?: true)])

      subject
    end

    it "raises an error when the bootstrapping process fails to find the requested extension point" do
      context.expects(:capture2e)
        .with(
          "npx --no-install shopify-scripts-toolchain-as bootstrap --from #{extension_point.type} --dest #{script_name}"
        )
        .returns(["", OpenStruct.new(success?: false)])

      assert_raises(Script::Layers::Domain::Errors::ServiceFailureError) { subject }
    end
  end
end
