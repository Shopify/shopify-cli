# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::Languages::RustTaskRunner do
  include TestHelpers::FakeFS
  let(:ctx) { TestHelpers::FakeContext.new }
  let(:script_id) { "id" }
  let(:script_name) { "foo" }
  let(:extension_point_config) do
    {
      "rust" => {
        "package": "https://github.com/Shopify/scripts-apis-rs",
        "beta": true,
      },
    }
  end
  let(:extension_point_type) { "payment_filter" }
  let(:language) { "rust" }
  let(:rs_task_runner) { Script::Layers::Infrastructure::Languages::RustTaskRunner.new(ctx, script_name) }

  def system_output(msg:, success:)
    [msg, OpenStruct.new(success?: success)]
  end

  describe ".build" do
    subject { rs_task_runner.build }
    it "should raise if the build command fails" do
      ctx
        .expects(:capture2e)
        .with("cargo build --target=wasm32-unknown-unknown --release")
        .returns(system_output(msg: "", success: false))

      assert_raises(Script::Layers::Infrastructure::Errors::SystemCallFailureError) { subject }
    end

    it "should raise if the generated wasm binary doesn't exist" do
      ctx
        .expects(:capture2e)
        .once
        .with("cargo build --target=wasm32-unknown-unknown --release")
        .returns(system_output(msg: "", success: true))

      ctx
        .expects(:file_exist?)
        .once
        .with("target/wasm32-unknown-unknown/release/script.wasm")
        .returns(false)

      assert_raises(Script::Layers::Infrastructure::Errors::WebAssemblyBinaryNotFoundError) { subject }
    end

    it "should return the compile bytecode" do
      ctx
        .expects(:capture2e)
        .once
        .with("cargo build --target=wasm32-unknown-unknown --release")
        .returns(system_output(msg: "", success: true))

      ctx
        .expects(:file_exist?)
        .once
        .with("target/wasm32-unknown-unknown/release/script.wasm")
        .returns(true)

      ctx
        .expects(:binread)
        .once
        .with("target/wasm32-unknown-unknown/release/script.wasm")
        .returns("blob")

      assert_equal "blob", subject
    end
  end

  describe ".metadata" do
    subject { rs_task_runner.metadata }

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
    subject { rs_task_runner.check_system_dependencies! }

    describe "when cargo is not installed" do
      it "should raise error" do
        ctx.expects(:capture2e)
          .with("cargo", "--version")
          .returns([nil, mock(success?: false)])
        assert_raises Script::Layers::Infrastructure::Errors::NoDependencyInstalledError do
          subject
        end
      end
    end

    describe "when cargo version is below minimum" do
      it "should raise error" do
        ctx.expects(:capture2e)
          .with("cargo", "--version")
          .returns(["1.49.0", mock(success?: true)])

        assert_raises Script::Layers::Infrastructure::Errors::MissingDependencyVersionError do
          subject
        end
      end
    end

    describe "when cargo version is above minimum" do
      it "should install successfully" do
        ctx.expects(:capture2e)
          .with("cargo", "--version")
          .returns(["1.50.1", mock(success?: true)])
        subject
      end
    end

    describe "when cargo version is the exact version" do
      it "should install successfully" do
        ctx.expects(:capture2e)
          .with("cargo", "--version")
          .returns(["1.50.0", mock(success?: true)])
        subject
      end
    end
  end
end
