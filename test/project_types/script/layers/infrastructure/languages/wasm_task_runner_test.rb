
require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::Languages::WasmTaskRunner do
  include TestHelpers::FakeFS

  let(:ctx) { TestHelpers::FakeContext.new }
  let(:library_name) { nil }
  let(:runner) { Script::Layers::Infrastructure::Languages::WasmTaskRunner.new(ctx) }

  describe ".dependencies_installed?" do
    subject { runner.dependencies_installed? }

    it "should always return true" do
      assert subject
    end
  end

  describe ".library_version" do
    subject { runner.library_version(library_name) }

    it "should always return nil" do
      assert_nil subject
    end
  end

  describe ".install_dependencies" do
    subject { runner.install_dependencies }

    it "should always return nil" do
      assert_nil subject
    end
  end

  describe ".metadata_file_location" do
    subject { runner.metadata_file_location }

    it "should return the file location" do
      assert_equal "metadata.json", subject
    end
  end

  describe ".build" do
    subject { runner.build }

    describe "when there is an existing .wasm file" do
      let(:wasm) { "some compiled code" }
      let(:wasmfile) { "script.wasm" }

      before do
        ctx.write(wasmfile, wasm)
      end
      it "should return the contents of the file" do
        assert_equal wasm, subject
      end
    end

    describe "when there is no existing .wasm file" do
      it "should raise an error" do
        assert_raises(Script::Layers::Infrastructure::Errors::WebAssemblyBinaryNotFoundError) do
          subject
        end
      end
    end
  end
end
