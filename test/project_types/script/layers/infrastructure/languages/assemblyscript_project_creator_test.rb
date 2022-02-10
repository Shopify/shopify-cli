# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::Languages::AssemblyScriptProjectCreator do
  include TestHelpers::FakeFS

  let(:context) { TestHelpers::FakeContext.new }

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

  let(:package_json_content) do
    {
      "name" => "default-name-from-examples-repo",
      "other" => "some other property",
    }
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

      Script::Layers::Infrastructure::Languages::AssemblyScriptTaskRunner.any_instance
        .expects(:set_npm_config)

      context
        .expects(:read)
        .with("package.json")
        .returns(package_json_content.to_json)

      new_content = package_json_content.dup
      new_content["name"] = project_name

      context
        .expects(:write)
        .with("package.json", JSON.pretty_generate(new_content))

      subject
    end
  end
end
