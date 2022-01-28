
require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::Languages::WasmTaskRunner do
  let(:ctx) { TestHelpers::FakeContext.new }
  let(:script_name) { "foo" }
  let(:library_name) { "@shopify/extension-point-as-fake" }
  let(:runner) { Script::Layers::Infrastructure::Languages::WasmTaskRunner.new(ctx, script_name) }

  describe ".dependencies_installed?" do
    subject { runner.dependencies_installed? }

    it "should always return true" do
      assert subject
    end
  end

  describe ".library_version" do
    subject { runner.library_version(library_name) }

    describe "regardless of the library_name" do
      it "should return nil" do
        assert_nil subject
      end
    end
  end
end
