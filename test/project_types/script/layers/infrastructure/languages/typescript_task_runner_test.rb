
require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::Languages::TypeScriptTaskRunner do
  include TestHelpers::FakeFS

  let(:ctx) { TestHelpers::FakeContext.new }
  let(:fake_capture2e_response) { [nil, OpenStruct.new(success?: true)] }
  let(:language) { "TypeScript" }
  let(:library_name) { "@shopify/extension-point-as-fake" }
  let(:runner) { Script::Layers::Infrastructure::Languages::TypeScriptTaskRunner.new(ctx) }
  let(:command_runner) { Script::Layers::Infrastructure::CommandRunner }
  let(:package_json) do
    {
      scripts: {
        build: "javy build/index.js -o build/index.wasm",
      },
    }
  end

  before do
    ShopifyCLI::Environment.stubs(
      node_version: ::Semantic::Version.new(runner.class::NODE_MIN_VERSION),
      npm_version: ::Semantic::Version.new(runner.class::NPM_MIN_VERSION)
    )
  end

  describe ".build" do
    subject { runner.build }

    it "should raise an error if no build script is defined" do
      File.expects(:read).with("package.json").once.returns(JSON.generate(package_json.delete(:scripts)))
      assert_raises(Script::Layers::Infrastructure::Errors::BuildScriptNotFoundError) do
        subject
      end
    end

    describe "when build script exists" do
      before do
        ctx.write("package.json", JSON.generate(package_json))
      end

      it "triggers the compilation and metadata generation processes" do
        ctx
          .expects(:capture2e)
          .with("npm run build")
          .once
          .returns(["output", mock(success?: true)])

        ctx
          .expects(:capture2e)
          .with("npm run gen-metadata")
          .once
          .returns(["output", mock(success?: true)])

        subject
      end
    end

    it "should raise build error when fails" do
      output = "error_output"
      File.expects(:read).with("package.json").once.returns(JSON.generate(package_json))
      File.expects(:read).never
      ctx
        .stubs(:capture2e)
        .returns([output, mock(success?: false)])

      assert_raises(Script::Layers::Infrastructure::Errors::BuildError, output) do
        subject
      end
    end
  end

  describe ".dependencies_installed?" do
    subject { runner.dependencies_installed? }

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
    subject { runner.install_dependencies }

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
          .returns(::Semantic::Version.new(decrement_version(runner.class::NODE_MIN_VERSION)))

        assert_raises Script::Layers::Infrastructure::Errors::InvalidEnvironmentError do
          subject
        end
      end
    end

    describe "when npm version is below minimum" do
      it "should raise error" do
        ShopifyCLI::Environment.expects(:npm_version)
          .returns(::Semantic::Version.new(decrement_version(runner.class::NPM_MIN_VERSION)))

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
    subject { runner.metadata_file_location }

    it "should return the filename" do
      assert_equal("build/metadata.json", subject)
    end
  end

  describe ".library_version" do
    subject { runner.library_version(library_name) }

    describe "when the package is in the dependencies list" do
      it "should return a valid version number" do
        command_runner.any_instance.stubs(:call)
          .with("npm -s list --json")
          .returns(
            {
              "dependencies" => {
                library_name => {
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
                  library_name => {
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

  describe ".set_npm_config" do
    subject { runner.set_npm_config }

    it "should run npm config commands" do
      ctx
        .expects(:capture2e)
        .with(Script::Layers::Infrastructure::Languages::TypeScriptTaskRunner::NPM_SET_REGISTRY_COMMAND)
        .returns(fake_capture2e_response)
      ctx
        .expects(:capture2e)
        .with(Script::Layers::Infrastructure::Languages::TypeScriptTaskRunner::NPM_SET_ENGINE_STRICT_COMMAND)
        .returns(fake_capture2e_response)

      subject
    end
  end

  private

  def decrement_version(version)
    major, minor, patch = version.split(".")
    [major.to_i - 1, minor, patch].join(".")
  end
end
