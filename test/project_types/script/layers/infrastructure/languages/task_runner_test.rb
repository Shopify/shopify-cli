# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::Languages::TaskRunner do
  describe "build" do
    subject { Script::Layers::Infrastructure::Languages::TaskRunner.for(@context, language) }

    describe "when the script language and compile type match an entry in the registry" do
      let(:language) { "typescript" }

      it "should return the entry from the registry" do
        Script::Layers::Infrastructure::Languages::TypeScriptTaskRunner
          .expects(:new)
          .with(@context)
        subject
      end
    end

    describe "when the script language and compile type doesn't match an entry in the registry" do
      let(:language) { "imaginary" }

      it "should raise a builder not found error" do
        Script::Layers::Infrastructure::Languages::TaskRunner
          .expects(:new)
          .with(@context)
        subject
      end
    end
  end
end
