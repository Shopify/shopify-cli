# typed: ignore
# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::Languages::TaskRunner do
  describe "build" do
    let(:script_name) { "script_name" }
    subject { Script::Layers::Infrastructure::Languages::TaskRunner.for(@context, language, script_name) }

    describe "when the script language and compile type match an entry in the registry" do
      let(:language) { "assemblyscript" }

      it "should return the entry from the registry" do
        Script::Layers::Infrastructure::Languages::AssemblyScriptTaskRunner
          .expects(:new)
          .with(@context, script_name)
        subject
      end
    end

    describe "when the script language and compile type doesn't match an entry in the registry" do
      let(:language) { "imaginary" }

      it "should raise a builder not found error" do
        assert_raises(Script::Layers::Infrastructure::Errors::TaskRunnerNotFoundError) { subject }
      end
    end
  end
end
