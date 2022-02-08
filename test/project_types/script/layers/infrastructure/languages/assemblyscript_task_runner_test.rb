# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::Languages::AssemblyScriptTaskRunner do
  include TestHelpers::FakeFS

  let(:ctx) { TestHelpers::FakeContext.new }
  let(:script_id) { "id" }
  let(:extension_point_config) do
    {
      "assemblyscript" => {
        "package": "@shopify/extension-point-as-fake",
        "version": "*",
      },
    }
  end
  let(:extension_point_type) { "discount" }
  let(:language) { "assemblyscript" }
  let(:as_task_runner) { Script::Layers::Infrastructure::Languages::AssemblyScriptTaskRunner.new(ctx) }
  let(:command_runner) { Script::Layers::Infrastructure::CommandRunner }
  let(:fake_capture2e_response) { [nil, OpenStruct.new(success?: true)] }

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

    it "should raise an error if the generated web assembly is not found" do
      ctx.write("package.json", JSON.generate(package_json))
      ctx
        .expects(:capture2e)
        .with("npm run build")
        .once
        .returns(["output", mock(success?: true)])

      assert_raises(Script::Layers::Infrastructure::Errors::WebAssemblyBinaryNotFoundError) { subject }
    end

    describe "when script.wasm exists"  do
      let(:wasm) { "some compiled code" }
      let(:wasmfile) { "build/script.wasm" }

      before do
        ctx.write("package.json", JSON.generate(package_json))
        ctx.mkdir_p(File.dirname(wasmfile))
        ctx.write(wasmfile, wasm)
      end

      it "triggers the compilation process" do
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

  describe ".dependencies_installed?" do
    subject { as_task_runner.dependencies_installed? }

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

  describe ".library_version" do
    subject { as_task_runner.library_version(extension_point_config["assemblyscript"][:package]) }

    describe "when the package is in the dependencies list" do
      it "should return a valid version number" do
        command_runner.any_instance.stubs(:call)
          .with("npm -s list --json")
          .returns(
            {
              "dependencies" => {
                extension_point_config["assemblyscript"][:package] => {
                  "version" => "1.3.7",
                },
              },
            }.to_json
          )
        assert_equal "1.3.7", subject
      end
    end

    describe "when the package is not in the dependencies list" do
      it "should return an error" do
        command_runner.any_instance.stubs(:call)
          .with("npm -s list --json")
          .returns(
            {
              "dependencies" => {},
            }.to_json,
          )
        assert_raises Script::Layers::Infrastructure::Errors::APILibraryNotFoundError do
          subject
        end
      end
    end

    describe "when CommandRunner raises SystemCallFailureError" do
      describe "when error is not json" do
        it "should re-raise SystemCallFailureError" do
          cmd = "npm -s list --json"
          command_runner.any_instance.stubs(:call)
            .with(cmd)
            .raises(Script::Layers::Infrastructure::Errors::SystemCallFailureError.new(
              out: "some non-json parsable error output",
              cmd: cmd
            ))

          assert_raises Script::Layers::Infrastructure::Errors::SystemCallFailureError do
            subject
          end
        end
      end

      describe "when error is json, but doesn't contain the expected structure" do
        it "should re-raise SystemCallFailureError" do
          cmd = "npm -s list --json"
          command_runner.any_instance.stubs(:call)
            .with(cmd)
            .raises(Script::Layers::Infrastructure::Errors::SystemCallFailureError.new(
              out: {
                "not what we expected" => {},
              }.to_json,
              cmd: cmd
            ))
          assert_raises Script::Layers::Infrastructure::Errors::SystemCallFailureError do
            subject
          end
        end
      end

      describe "when error contains expected versioning data" do
        it "should rescue SystemCallFailureError if the library version is present" do
          cmd = "npm -s list --json"
          command_runner.any_instance.stubs(:call)
            .with(cmd)
            .raises(Script::Layers::Infrastructure::Errors::SystemCallFailureError.new(
              out: {
                "dependencies" => {
                  extension_point_config["assemblyscript"][:package] => {
                    "version" => "1.3.7",
                  },
                },
              }.to_json,
              cmd: cmd
            ))
          assert_equal "1.3.7", subject
        end
      end
    end
  end

  describe ".install_dependencies" do
    subject { as_task_runner.install_dependencies }

    before do
      ShopifyCLI::Environment.stubs(:node_version)
        .returns(::Semantic::Version.new("14.15.0"))
      ShopifyCLI::Environment.stubs(:npm_version)
        .returns(::Semantic::Version.new("5.2.0"))
    end

    describe "when node version is above minimum" do
      it "should install using npm" do
        ctx.expects(:capture2e)
          .with("npm install --no-audit --no-optional --legacy-peer-deps --loglevel error")
          .returns([nil, mock(success?: true)])
        subject
      end
    end

    describe "when node version is below minimum" do
      it "should raise error" do
        ShopifyCLI::Environment.expects(:node_version)
          .returns(::Semantic::Version.new("14.14.0"))

        assert_raises Script::Layers::Infrastructure::Errors::InvalidEnvironmentError do
          subject
        end
      end
    end

    describe "when capture2e fails" do
      it "should raise error" do
        msg = "error message"
        ctx.expects(:capture2e).returns([msg, mock(success?: false)])
        assert_raises Script::Layers::Infrastructure::Errors::DependencyInstallError, msg do
          subject
        end
      end
    end
  end

  describe ".metadata_file_location" do
    subject { as_task_runner.metadata_file_location }

    it "should return the filename" do
      assert_equal("build/metadata.json", subject)
    end
  end

  describe ".set_npm_config" do
    subject { as_task_runner.set_npm_config }

    it "should run npm config commands" do
      ctx
        .expects(:capture2e)
        .with(Script::Layers::Infrastructure::Languages::AssemblyScriptTaskRunner::NPM_SET_REGISTRY_COMMAND)
        .returns(fake_capture2e_response)
      ctx
        .expects(:capture2e)
        .with(Script::Layers::Infrastructure::Languages::AssemblyScriptTaskRunner::NPM_SET_ENGINE_STRICT_COMMAND)
        .returns(fake_capture2e_response)

      subject
    end
  end

  describe ".ensure_environment" do
    subject { as_task_runner.ensure_environment }

    it "should call check_tool_versions with tools" do
      as_task_runner
        .expects(:check_tool_versions)
        .with(as_task_runner.class::TOOLS)
      subject
    end
  end
end
