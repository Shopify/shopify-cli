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
        "sdk-version" => "*",
        "toolchain-version" => "*",
      },
    }
  end

  let(:domain) { "fake-domain" }
  let(:type) { extension_point_type }
  let(:repo) { extension_point_config["assemblyscript"]["repo"] }
  let(:script_name) { "myscript" }
  let(:branch) { "fake-branch" }

  let(:project_creator) do
    Script::Layers::Infrastructure::Languages::AssemblyScriptProjectCreator
      .new(
        ctx: context,
        domain: domain,
        type: type,
        repo: repo,
        script_name: script_name,
        path_to_project: script_name,
        branch: branch
      )
  end

  before do
    context.mkdir_p(script_name)
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
