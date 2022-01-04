# typed: ignore
# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::CommandRunner do
  include TestHelpers::FakeFS

  let(:context) { TestHelpers::FakeContext.new }
  let(:command_runner) { Script::Layers::Infrastructure::CommandRunner.new(ctx: context) }
  let(:cmd) { "some_cmd -v" }
  let(:expected_output) { "some output" }

  def system_output(msg:, success:)
    [msg, OpenStruct.new(success?: success)]
  end

  describe ".call" do
    subject { command_runner.call(cmd) }

    describe "on success" do
      it "returns the output" do
        context.expects(:capture2e).with(cmd).returns(system_output(msg: expected_output, success: true))
        assert_equal expected_output, subject
      end
    end

    describe "on failure" do
      it "raises SystemCallFailureError" do
        context.expects(:capture2e).with(cmd).returns(system_output(msg: expected_output, success: false))
        e = assert_raises(Script::Layers::Infrastructure::Errors::SystemCallFailureError) { subject }
        assert_equal expected_output, e.message
      end
    end
  end
end
