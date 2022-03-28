# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::SparseCheckoutDetails do
  let(:repo) { "fake-repo" }
  let(:branch) { "fake-branch" }
  let(:path) { "fake-path" }
  let(:input_queries_enabled) { false }
  let(:instance) do
    Script::Layers::Infrastructure::SparseCheckoutDetails.new(
      repo: repo,
      branch: branch,
      path: path,
      input_queries_enabled: input_queries_enabled,
    )
  end

  describe "#==" do
    subject { instance == other_instance }

    describe "when the other instance has all the same properties" do
      let(:other_instance) do
        Script::Layers::Infrastructure::SparseCheckoutDetails.new(
          repo: repo,
          branch: branch,
          path: path,
          input_queries_enabled: input_queries_enabled,
        )
      end

      it "returns true" do
        assert(subject)
      end
    end

    describe "when the other instance has different properties" do
      let(:other_instance) do
        Script::Layers::Infrastructure::SparseCheckoutDetails.new(
          repo: repo,
          branch: branch,
          path: path,
          input_queries_enabled: !input_queries_enabled,
        )
      end

      it "returns false" do
        refute(subject)
      end
    end
  end

  describe "#setup" do
    let(:context) { TestHelpers::FakeContext.new }

    subject { instance.setup(context) }

    describe "input_queries_enabled is false" do
      it "excludes input.graphql and schema.graphql from set path" do
        ShopifyCLI::Git
          .expects(:sparse_checkout)
          .with(
            repo,
            "#{path} !#{path}/input.graphql !#{path}/schema.graphql",
            branch,
            context,
          )
          .once
        subject
      end
    end

    describe "input_queries_enabled is true" do
      let(:input_queries_enabled) { true }

      it "does not exclude input.graphql and schema.graphql from set path" do
        ShopifyCLI::Git
          .expects(:sparse_checkout)
          .with(
            repo,
            path,
            branch,
            context,
          )
          .once
        subject
      end
    end
  end
end
