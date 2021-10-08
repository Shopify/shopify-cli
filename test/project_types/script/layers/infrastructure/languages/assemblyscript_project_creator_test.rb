# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::Languages::AssemblyScriptProjectCreator do
  include TestHelpers::FakeFS

  let(:context) { TestHelpers::FakeContext.new }
  let(:fake_capture2e_response) { [nil, OpenStruct.new(success?: true)] }

  let(:extension_point_type) { "payment_methods" }
  let(:extension_point_config) do
    {
      "assemblyscript" => {
        "repo" => "https://github.com/Shopify/extension-points.git",
        "package" => "@shopify/extension-point-as-fake",
        "toolchain-version" => "*",
      },
    }
  end

  let(:domain) { "fake-domain" }
  let(:project_name) { "myscript" }
  let(:sparse_checkout_repo) { extension_point_config["assemblyscript"]["repo"] }
  let(:sparse_checkout_branch) { "fake-branch" }
  let(:sparse_checkout_set_path) { "packages/#{domain}/samples/#{extension_point_type}" }

  let(:project_creator) do
    Script::Layers::Infrastructure::Languages::AssemblyScriptProjectCreator
      .new(
        ctx: context,
        type: extension_point_type,
        project_name: project_name,
        path_to_project: project_name,
        sparse_checkout_repo: sparse_checkout_repo,
        sparse_checkout_branch: sparse_checkout_branch,
        sparse_checkout_set_path: sparse_checkout_set_path,
      )
  end

  before do
    context.mkdir_p(project_name)
  end

  describe ".setup_dependencies" do
    subject { project_creator.setup_dependencies }

    it "should setup dependencies" do
      Script::Layers::Infrastructure::Languages::ProjectCreator.any_instance
        .expects(:setup_dependencies)
        .with
        .once

      context
        .expects(:capture2e)
        .with(Script::Layers::Infrastructure::Languages::AssemblyScriptProjectCreator::NPM_SET_REGISTRY_COMMAND)
        .returns(fake_capture2e_response)
      context
        .expects(:capture2e)
        .with(Script::Layers::Infrastructure::Languages::AssemblyScriptProjectCreator::NPM_SET_ENGINE_STRICT_COMMAND)
        .returns(fake_capture2e_response)

      subject
    end
  end
end
