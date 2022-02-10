# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::Languages::ToolVersionChecker do
  describe ".check_node" do
    subject do
      Script::Layers::Infrastructure::Languages::ToolVersionChecker
        .check_node(minimum_version: minimum_version)
    end

    describe "when version is acceptable" do
      let(:minimum_version) { "1.0.0" }

      it "should return true" do
        ShopifyCLI::Environment.expects(:node_version).returns(::Semantic::Version.new("1.0.0"))
        subject
      end
    end

    describe "when version is outdated" do
      let(:minimum_version) { "5.0.0" }

      it "should should raise DependencyInstallError" do
        ShopifyCLI::Environment.expects(:node_version).returns(::Semantic::Version.new("1.0.0"))
        assert_raises(Script::Layers::Infrastructure::Errors::InvalidEnvironmentError) { subject }
      end
    end
  end

  describe ".check_npm" do
    subject do
      Script::Layers::Infrastructure::Languages::ToolVersionChecker
        .check_npm(minimum_version: minimum_version)
    end

    describe "when version is acceptable" do
      let(:minimum_version) { "1.0.0" }

      it "should return true" do
        ShopifyCLI::Environment.expects(:npm_version).returns(::Semantic::Version.new("1.0.0"))
        subject
      end
    end

    describe "when version is outdated" do
      let(:minimum_version) { "5.0.0" }

      it "should should raise DependencyInstallError" do
        ShopifyCLI::Environment.expects(:npm_version).returns(::Semantic::Version.new("1.0.0"))
        assert_raises(Script::Layers::Infrastructure::Errors::InvalidEnvironmentError) { subject }
      end
    end
  end
end
