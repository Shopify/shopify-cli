# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::Languages::TaskRunner do
  let(:ctx) { TestHelpers::FakeContext.new }
  let(:language) { "assemblyscript" }
  let(:script_name) { "script_name" }
  let(:task_runner) { Script::Layers::Infrastructure::Languages::TaskRunner.for(ctx, language, script_name) }

  describe "build" do
    subject { task_runner }

    describe "when the script language and compile type match an entry in the registry" do
      it "should return the entry from the registry" do
        Script::Layers::Infrastructure::Languages::AssemblyScriptTaskRunner
          .expects(:new)
          .with(ctx, script_name)
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

  describe "check_tool_version!" do
    let(:tool) { "npm" }
    let(:tool_version) { EXACT_NPM_VERSION }

    subject { task_runner.send(:check_tool_version!, tool, tool_version) }

    EXACT_NODE_VERSION = "14.15.0"

    BELOW_NPM_VERSION = "5.1.0"
    EXACT_NPM_VERSION = "5.2.0"

    describe "when tool version is not installed" do
      it "should raise error" do
        ctx.expects(:capture2e)
          .with("npm", "--version")
          .returns([nil, mock(success?: false)])
        assert_raises Script::Layers::Infrastructure::Errors::NoDependencyInstalledError do
          subject
        end
      end
    end

    describe "when tool version is installed and good" do
      it "should install successfully" do
        ctx.expects(:capture2e)
          .with("npm", "--version")
          .returns([EXACT_NPM_VERSION, mock(success?: true)])

        subject
      end
    end

    describe "when tool version is installed and outdated" do
      it "should install successfully" do
        ctx.expects(:capture2e)
          .with("npm", "--version")
          .returns([BELOW_NPM_VERSION, mock(success?: true)])

        assert_raises Script::Layers::Infrastructure::Errors::MissingDependencyVersionError do
          subject
        end
      end
    end

    describe "when provided tool version has a v pre-fix" do
      let(:tool) { "node" }
      let(:tool_version) { EXACT_NODE_VERSION }

      it "should remove successfully" do
        ctx.expects(:capture2e)
          .with("node", "--version")
          .returns(["v14.15.1", mock(success?: true)])

        subject
      end
    end
  end
end
