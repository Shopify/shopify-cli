# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::ConfigUiRepository do
  include TestHelpers::FakeFS

  let(:ctx) { TestHelpers::FakeContext.new }
  let(:instance) { Script::Layers::Infrastructure::ConfigUiRepository.new(ctx: ctx) }

  describe "#create_config_ui" do
    let(:filename) { "filename" }
    let(:content) { "content" }

    subject { instance.create_config_ui(filename, content) }

    it "should write the content to the filename" do
      subject
      assert_equal content, File.read(filename)
    end

    it "should return a ConfigUi entity" do
      assert subject.is_a?(Script::Layers::Domain::ConfigUi)
    end
  end

  describe "#get_config_ui" do
    subject { instance.get_config_ui(filename) }

    describe "when filename is empty" do
      let(:filename) { nil }

      it "should return nil" do
        assert_nil subject
      end
    end

    describe "when filename is not empty" do
      let(:filename) { "filename" }

      describe "when file does not exist" do
        it "raises MissingSpecifiedConfigUiDefinitionError" do
          assert_raises(Script::Layers::Domain::Errors::MissingSpecifiedConfigUiDefinitionError) { subject }
        end
      end

      describe "when file exists" do
        before do
          File.write(filename, content)
        end

        describe "when content is invalid yaml" do
          let(:content) { "*" }

          it "raises InvalidConfigUiDefinitionError" do
            assert_raises(Script::Layers::Domain::Errors::InvalidConfigUiDefinitionError) { subject }
          end
        end

        describe "when content is valid yaml" do
          let(:content) { "---\nversion: 1" }

          it "returns the entity" do
            assert_equal filename, subject.filename
            assert_equal content, subject.content
          end
        end
      end
    end
  end
end
