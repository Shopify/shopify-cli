# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::Languages::WasmProjectCreator do
  include TestHelpers::FakeFS

  let(:context) { TestHelpers::FakeContext.new }

  let(:type) { "payment-methods" }
  let(:language) { "wasm" }
  let(:domain) { "fake-domain" }
  let(:project_name) { "myscript" }
  let(:sparse_checkout_details) do
    Script::Layers::Infrastructure::SparseCheckoutDetails.new(
      repo: "fake-repo",
      branch: "fake-branch",
      path: "#{domain}/#{language}/#{type}/default",
      input_queries_enabled: false,
    )
  end
  let(:project_creator) do
    Script::Layers::Infrastructure::Languages::WasmProjectCreator
      .new(
        ctx: context,
        type: type,
        project_name: project_name,
        path_to_project: project_name,
        sparse_checkout_details: sparse_checkout_details,
      )
  end

  describe ".setup_dependencies" do
    subject { project_creator.setup_dependencies }

    it "should setup basic script project files" do
      Script::Layers::Infrastructure::Languages::ProjectCreator.any_instance
        .expects(:setup_dependencies)
        .with
        .once

      subject
    end
  end
end
