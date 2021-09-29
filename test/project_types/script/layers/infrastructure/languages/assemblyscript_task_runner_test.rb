# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::Languages::AssemblyScriptTaskRunner do
  include TestHelpers::FakeFS

  BELOW_NODE_VERSION = "v14.4.0"
  EXACT_NODE_VERSION = "v14.5.0"
  ABOVE_NODE_VERSION = "v14.6.0"

  ABOVE_NPM_VERSION = "5.2.1"
  EXACT_NPM_VERSION = "5.2.0"

  let(:ctx) { TestHelpers::FakeContext.new }
  let(:script_id) { "id" }
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
  let(:language) { "AssemblyScript" }
  let(:as_task_runner) { Script::Layers::Infrastructure::Languages::AssemblyScriptTaskRunner.new(ctx, script_name) }

  let(:package_json) do
    {
      scripts: {
        build: "shopify-scripts-toolchain-as build --src src/shopify_main.ts -b script.wasm -- --lib node_modules",
      },
    }
  end

  describe ".build" do
    subject { as_task_runner.build }

    it "should raise an error if no build script is defined" do
      File.expects(:read).with("package.json").once.returns(JSON.generate(package_json.delete(:scripts)))
      assert_raises(Script::Layers::Infrastructure::Errors::BuildScriptNotFoundError) do
        subject
      end
    end

    it "should raise an error if the build script is not compliant" do
      package_json[:scripts][:build] = ""
      File.expects(:read).with("package.json").once.returns(JSON.generate(package_json))
      assert_raises(Script::Layers::Infrastructure::Errors::InvalidBuildScriptError) do
        subject
      end
    end

    it "should raise an error if the generated web assembly is not found" do
      ctx.write("package.json", JSON.generate(package_json))
      ctx
        .expects(:capture2e)
        .with("npm run build")
        .once
        .returns(["output", mock(success?: true)])

      assert_raises(Script::Layers::Infrastructure::Errors::WebAssemblyBinaryNotFoundError) { subject }
    end

    describe "success" do
      def self.it_triggers_compilation_process
        it("triggers the compilation process") do
          wasm = "some compiled code"
          ctx.write("package.json", JSON.generate(package_json))
          ctx.mkdir_p(File.dirname(wasmfile))
          ctx.write(wasmfile, wasm)

          ctx
            .expects(:capture2e)
            .with("npm run build")
            .once
            .returns(["output", mock(success?: true)])

          assert ctx.file_exist?(wasmfile)
          assert_equal wasm, subject
          refute ctx.file_exist?(wasmfile)
        end
      end

      describe "legacy naming" do
        let(:wasmfile) { "build/#{script_name}.wasm" }

        it_triggers_compilation_process
      end

      describe "new naming" do
        let(:wasmfile) { "build/script.wasm" }

        it_triggers_compilation_process
      end
    end

    it "should raise error without command output on failure" do
      output = "error_output"
      File.expects(:read).with("package.json").once.returns(JSON.generate(package_json))
      File.expects(:read).never
      ctx
        .stubs(:capture2e)
        .returns([output, mock(success?: false)])

      assert_raises(Script::Layers::Infrastructure::Errors::SystemCallFailureError, output) do
        subject
      end
    end
  end

  describe ".project_dependencies_installed??" do
    subject { as_task_runner.project_dependencies_installed? }

    before do
      FileUtils.mkdir_p("node_modules")
    end

    it "should return true if node_modules folder exists" do
      assert subject
    end

    it "should return false if node_modules folder does not exists" do
      Dir.stubs(:exist?).returns(false)
      refute subject
    end
  end

  describe ".install_dependencies" do
    subject { as_task_runner.install_dependencies }

    def stub_tool_versions(npm:, node:)
      ctx.stubs(:capture2e)
        .with("npm", "--version")
        .returns([npm, mock(success?: true)])
      ctx.stubs(:capture2e)
        .with("node", "--version")
        .returns([node, mock(success?: true)])
    end

    describe "when npm version and node are above minimum" do
      describe "when npm packages fail to install" do
        it "should raise error" do
          stub_tool_versions(npm: EXACT_NPM_VERSION, node: EXACT_NODE_VERSION)
          ctx.expects(:capture2e)
            .with("npm install --no-audit --no-optional --legacy-peer-deps --loglevel error")
            .returns([nil, mock(success?: false)])
          assert_raises Script::Layers::Infrastructure::Errors::DependencyInstallationError do
            subject
          end
        end
      end

      describe "when npm packages install" do
        it "should successfully install" do
          stub_tool_versions(npm: EXACT_NPM_VERSION, node: EXACT_NODE_VERSION)
          ctx.expects(:capture2e)
            .with("npm install --no-audit --no-optional --legacy-peer-deps --loglevel error")
            .returns([nil, mock(success?: true)])
          subject
        end
      end

      describe "when capture2e fails" do
        it "should raise error" do
          msg = "error message"
          ctx.expects(:capture2e)
            .with("npm", "--version")
            .returns([EXACT_NPM_VERSION, mock(success?: true)])
          ctx.expects(:capture2e)
            .with("node", "--version")
            .returns([EXACT_NODE_VERSION, mock(success?: true)])
          ctx.expects(:capture2e)
            .with("npm install --no-audit --no-optional --legacy-peer-deps --loglevel error")
            .returns([msg, mock(success?: false)])
          assert_raises Script::Layers::Infrastructure::Errors::DependencyInstallationError, msg do
            subject
          end
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
              example: { major: "1", minor: "0" },
            },
          },
        )
      end

      it "should return a proper metadata object" do
        File.expects(:read).with("build/metadata.json").once.returns(metadata_json)

        ctx
          .expects(:file_exist?)
          .with("build/metadata.json")
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

  describe ".check_system_dependencies!" do
    subject { as_task_runner.check_system_dependencies! }

    describe "when npm is not installed" do
      it "should raise error" do
        ctx.expects(:capture2e)
          .with("npm", "--version")
          .returns([nil, mock(success?: false)])
        assert_raises Script::Layers::Infrastructure::Errors::NoDependencyInstalledError do
          subject
        end
      end
    end

    describe "when node is not installed" do
      it "should raise error" do
        ctx.expects(:capture2e)
          .with("npm", "--version")
          .returns([EXACT_NODE_VERSION, mock(success?: true)])
        ctx.expects(:capture2e)
          .with("node", "--version")
          .returns([nil, mock(success?: false)])
        assert_raises Script::Layers::Infrastructure::Errors::NoDependencyInstalledError do
          subject
        end
      end
    end

    describe "when npm version is below minimum" do
      it "should raise error" do
        ctx.expects(:capture2e)
          .with("npm", "--version")
          .returns([nil, mock(success?: false)])

        assert_raises Script::Layers::Infrastructure::Errors::NoDependencyInstalledError do
          subject
        end
      end
    end

    def stub_tool_versions(npm:, node:)
      ctx.stubs(:capture2e)
        .with("npm", "--version")
        .returns([npm, mock(success?: true)])
      ctx.stubs(:capture2e)
        .with("node", "--version")
        .returns([node, mock(success?: true)])
    end

    describe "when npm version is above minimum" do
      describe "when node version is below minimum" do
        it "should raise error" do
          stub_tool_versions(npm: ABOVE_NPM_VERSION, node: BELOW_NODE_VERSION)
          assert_raises Script::Layers::Infrastructure::Errors::MissingDependencyVersionError do
            subject
          end
        end
      end

      describe "when node version is above minimum" do
        it "should install successfully" do
          stub_tool_versions(npm: ABOVE_NPM_VERSION, node: ABOVE_NODE_VERSION)
          subject
        end
      end

      describe "when node version is the exact version" do
        it "should install successfully" do
          stub_tool_versions(npm: ABOVE_NPM_VERSION, node: EXACT_NODE_VERSION)
          subject
        end
      end
    end

    describe "when npm version is exactly the version" do
      describe "when node version is below minimum" do
        it "should raise error" do
          stub_tool_versions(npm: EXACT_NPM_VERSION, node: BELOW_NODE_VERSION)
          assert_raises Script::Layers::Infrastructure::Errors::MissingDependencyVersionError do
            subject
          end
        end
      end

      describe "when node version is above minimum" do
        it "should install successfully" do
          stub_tool_versions(npm: EXACT_NPM_VERSION, node: ABOVE_NODE_VERSION)
          subject
        end
      end

      describe "when node version is the exact version" do
        it "should install successfully" do
          stub_tool_versions(npm: EXACT_NPM_VERSION, node: EXACT_NODE_VERSION)
          subject
        end
      end
    end
  end
end
