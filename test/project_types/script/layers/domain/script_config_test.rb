# typed: ignore
# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Domain::ScriptConfig do
  let(:content) do
    {
      "version" => "1",
      "title" => "Some Title",
      "description" => "Some Description",
      "configurationUi" => true,
      "configuration" => {},
    }
  end

  subject { Script::Layers::Domain::ScriptConfig.new(content: content) }

  describe "#initialize" do
    it "constructs a ScriptConfig" do
      assert_equal("1", subject.version)
      assert_equal("Some Title", subject.title)
      assert_equal("Some Description", subject.description)
      assert(subject.configuration_ui)
      assert_equal({}, subject.configuration)
    end
  end

  describe "#configuration_ui" do
    describe "when configurationUi key is not provided" do
      let(:content) { { "version" => "1", "title" => "Title" } }

      it("is true") { assert(subject.configuration_ui) }
    end

    describe "when configurationUi is false" do
      let(:content) { { "version" => "1", "title" => "Title", "configurationUi" => false } }

      it("is false") { refute(subject.configuration_ui) }
    end
  end
end
