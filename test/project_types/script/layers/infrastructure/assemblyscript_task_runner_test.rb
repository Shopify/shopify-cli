# frozen_string_literal: true

require 'project_types/script/test_helper'

describe Script::Layers::Infrastructure::AssemblyScriptTaskRunner do
  include TestHelpers::FakeFS

  let(:ctx) { TestHelpers::FakeContext.new }
  let(:script_id) { 'id' }
  let(:script_name) { "foo" }
  let(:script_source) { 'script.ts' }
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
  let(:as_task_runner) { Script::Layers::Infrastructure::AssemblyScriptTaskRunner.new(ctx, script_name, script_source) }
  let(:script_project) do
    TestHelpers::FakeScriptProject
      .new(language: language, extension_point_type: extension_point_type, script_name: script_name)
  end

  let(:package_json) do
    {
      scripts: {
        build: "shopify-scripts-toolchain-as build --src src/script.ts -b script.wasm -- --lib node_modules",
      },
    }
  end

  before do
    Script::ScriptProject.stubs(:current).returns(script_project)
  end

  describe ".build" do
    subject { as_task_runner.build }

    it "should raise an error if no build script is defined" do
      File.expects(:read).with('package.json').once.returns(JSON.generate(package_json.delete(:scripts)))
      assert_raises(Script::Layers::Infrastructure::Errors::BuildScriptNotFoundError) do
        subject
      end
    end

    it "should raise an error if the build script is not compliant" do
      package_json[:scripts][:build] = ""
      File.expects(:read).with('package.json').once.returns(JSON.generate(package_json))
      assert_raises(Script::Layers::Infrastructure::Errors::InvalidBuildScriptError) do
        subject
      end
    end

    it "should raise an error if the generated web assembly is not found" do
      File.expects(:read).with('package.json').once.returns(JSON.generate(package_json))
      ctx
        .expects(:file_exist?)
        .with('build/foo.wasm')
        .once
        .returns(false)

      ctx
        .expects(:capture2e)
        .with("npm run build")
        .once
        .returns(['output', mock(success?: true)])

      assert_raises(Script::Layers::Infrastructure::Errors::WebAssemblyBinaryNotFoundError) { subject }
    end

    it "should trigger the compilation process" do
      wasm = "some compiled code"
      File.expects(:read).with('package.json').once.returns(JSON.generate(package_json))
      File.expects(:read).with('build/foo.wasm').once.returns(wasm)

      ctx
        .expects(:capture2e)
        .with("npm run build")
        .once
        .returns(['output', mock(success?: true)])

      ctx
        .expects(:file_exist?)
        .with('build/foo.wasm')
        .once
        .returns(true)

      ctx.expects('rm').with('build/foo.wasm').once

      assert_equal wasm, subject
    end

    it "should raise error without command output on failure" do
      output = 'error_output'
      File.expects(:read).with('package.json').once.returns(JSON.generate(package_json))
      File.expects(:read).never
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

    before do
      FileUtils.mkdir_p("node_modules")
    end

    it "should return true if node_modules folder exists" do
      stub_npm_outdated({})
      assert subject
    end

    it "should return false if node_modules folder does not exists" do
      Dir.stubs(:exist?).returns(false)
      stub_npm_outdated({})
      refute subject
    end

    it "should not error if `npm outdated` returns nothing" do
      stub_npm_outdated({})
      subject
    end

    it "should not error if `npm outdated` does not return an EP package" do
      stub_npm_outdated(create_package_version_info(package_name: "somepackage"))
      subject
    end

    it "should not error if current version is linked" do
      stub_npm_outdated(create_package_version_info(current: "linked"))
      subject
    end

    it "should not error if latest version is an https URL" do
      stub_npm_outdated(create_package_version_info(latest: "https://github.com/somethingsomething"))
      subject
    end

    it "should not error if patch version is different" do
      stub_npm_outdated(create_package_version_info(current: "0.9.0", latest: "0.9.1"))
      subject
    end

    it "should not error if it's a non-zero major version and minor version is different" do
      stub_npm_outdated(create_package_version_info(current: "1.0.0", latest: "1.1.0"))
      subject
    end

    it "should error if it's a zero major version and minor version is different" do
      package_name = "@shopify/extension-point-as-foo"
      stub_npm_outdated(create_package_version_info(package_name: package_name, current: "0.9.0", latest: "0.10.0"))
      msg = "NPM packages out of date: #{package_name}"
      error = assert_raises Script::Layers::Infrastructure::Errors::PackagesOutdatedError, msg do
        subject
      end
      assert_equal msg, error.message
    end

    it "should error if major version is different" do
      package_name = "@shopify/extension-point-as-foo"
      stub_npm_outdated(create_package_version_info(package_name: package_name, current: "0.9.0", latest: "1.0.0"))
      msg = "NPM packages out of date: #{package_name}"
      error = assert_raises Script::Layers::Infrastructure::Errors::PackagesOutdatedError do
        subject
      end
      assert_equal msg, error.message
    end
  end

  describe ".install_dependencies" do
    subject { as_task_runner.install_dependencies }

    describe "when node version is above minimum" do
      it "should install using npm" do
        ctx.expects(:capture2e)
          .with("node", "--version")
          .returns(["v14.5.1", mock(success?: true)])
        ctx.expects(:capture2e)
          .with("npm", "install", "--no-audit", "--no-optional", "--loglevel error")
          .returns([nil, mock(success?: true)])
        subject
      end
    end

    describe "when node version is below minimum" do
      it "should raise error" do
        ctx.expects(:capture2e)
          .with("node", "--version")
          .returns(["v14.4.0", mock(success?: true)])

        assert_raises Script::Layers::Infrastructure::Errors::DependencyInstallError do
          subject
        end
      end
    end

    describe "when capture2e fails" do
      it "should raise error" do
        msg = 'error message'
        ctx.expects(:capture2e).returns([msg, mock(success?: false)])
        assert_raises Script::Layers::Infrastructure::Errors::DependencyInstallError, msg do
          subject
        end
      end
    end
  end

  describe ".metadata" do
    subject { as_task_runner.metadata }

    describe "when metadata file is present and valid" do
      let(:metadata_json) do
        JSON.dump(
          {
            schemaVersions: {
              example: { major: '1', minor: '0' },
            },
          },
        )
      end

      it "should return a proper metadata object" do
        File.expects(:read).with('build/metadata.json').once.returns(metadata_json)

        ctx
          .expects(:file_exist?)
          .with('build/metadata.json')
          .once
          .returns(true)

        assert subject
      end
    end

    describe "when metadata file is missing" do
      it "should raise an exception" do
        assert_raises(Script::Layers::Domain::Errors::MetadataNotFoundError) do
          subject
        end
      end
    end
  end

  private

  def stub_npm_outdated(output)
    ctx.stubs(:capture2e)
      .with("npm", "outdated", "--json", "--depth", "0")
      .returns([output.to_json, mock])
  end

  def create_package_version_info(package_name: "@shopify/extension-point-as-foo", current: "0.9.0", latest: "0.10.0")
    { package_name => { "current" => current, "latest" => latest } }
  end
end
