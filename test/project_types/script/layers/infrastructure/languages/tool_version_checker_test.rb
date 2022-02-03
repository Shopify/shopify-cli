# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::Languages::ToolVersionChecker do
  let(:checker) { ToolVersionCheckerTester.new }
  let(:tools) do
    {
      "node" => {
        "minimum_version" => "1.0.0",
      },
      "npm" => {
        "minimum_version" => "2.0.0",
      },
    }
  end

  describe ".check_tool_versions" do
    subject { checker.check_tool_versions(tools) }

    describe "when all tool versions acceptable" do
      it "should return true" do
        ShopifyCLI::Environment.expects(:node_version).returns(::Semantic::Version.new("1.0.0"))
        ShopifyCLI::Environment.expects(:npm_version).returns(::Semantic::Version.new("2.0.0"))

        subject
      end
    end

    describe "when some tool versions are outdated" do
      it "should raise DependencyInstallError" do
        ShopifyCLI::Environment.expects(:node_version).returns(::Semantic::Version.new("1.0.0"))
        ShopifyCLI::Environment.expects(:npm_version).returns(::Semantic::Version.new("1.0.0"))

        assert_raises(Script::Layers::Infrastructure::Errors::DependencyInstallError) { subject }
      end
    end
  end
end

class ToolVersionCheckerTester
  include Script::Layers::Infrastructure::Languages::ToolVersionChecker
end
