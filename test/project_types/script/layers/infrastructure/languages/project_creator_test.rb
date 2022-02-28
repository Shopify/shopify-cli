# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::Languages::ProjectCreator do
  include TestHelpers::FakeFS

  let(:context) { TestHelpers::FakeContext.new }
  let(:language) { "assemblyscript" }

  let(:domain) { "fake-domain" }
  let(:extension_point_type) { "fake-ep-type" }
  let(:project_name) { "myscript" }

  let(:path) { "project_path" }

  let(:sparse_checkout_repo) { "fake-repo" }
  let(:sparse_checkout_branch) { "fake-branch" }
  let(:sparse_checkout_set_path) { "packages/#{domain}/samples/#{extension_point_type}" }

  let(:source) { File.join(path, sparse_checkout_set_path) }

  let(:project_creator) do
    Script::Layers::Infrastructure::Languages::ProjectCreator.new(
      ctx: context,
      type: extension_point_type,
      project_name: project_name,
      path_to_project: path,
      sparse_checkout_repo: sparse_checkout_repo,
      sparse_checkout_branch: sparse_checkout_branch,
      sparse_checkout_set_path: sparse_checkout_set_path
    )
  end

  let(:fake_capture2e_response) { [nil, OpenStruct.new(success?: true)] }
  def system_output(msg:, success:)
    [msg, OpenStruct.new(success?: success)]
  end

  describe ".for" do
    subject do
      Script::Layers::Infrastructure::Languages::ProjectCreator
        .for(
          ctx: context,
          language: language,
          type: extension_point_type,
          project_name: project_name,
          path_to_project: path,
          sparse_checkout_repo: sparse_checkout_repo,
          sparse_checkout_branch: sparse_checkout_branch,
          sparse_checkout_set_path: sparse_checkout_set_path,
        )
    end

    describe "when the script language is AssemblyScript" do
      it "should return the AssemblyScriptProjectCreator" do
        assert_instance_of(Script::Layers::Infrastructure::Languages::AssemblyScriptProjectCreator, subject)
      end
    end

    describe "when the script language doesn't match an entry in the registry" do
      let(:language) { "ArnoldC" }

      it "should raise dependency not supported error" do
        assert_raises(Script::Layers::Infrastructure::Errors::ProjectCreatorNotFoundError) { subject }
      end
    end
  end

  describe ".setup_dependencies" do
    subject { project_creator.setup_dependencies }

    describe "when Git sparse checkout is successful" do
      before do
        ShopifyCLI::Git
          .expects(:sparse_checkout)
          .with(
            project_creator.sparse_checkout_repo,
            project_creator.sparse_checkout_set_path,
            project_creator.sparse_checkout_branch,
            context
          )
          .once

        # setup the directory and files that sparse-checkout would produce
        FileUtils.mkdir_p(source)
        FileUtils.mkdir_p(".git")
      end

      it "should sucessfully setup dependencies" do
        context.expects(:rm_rf).with(project_creator.sparse_checkout_set_path.split("/")[0])
        context.expects(:rm_rf).with(".git")

        subject
      end
    end

    describe "when Git sparse checkout throws error" do
      it "shouuld also throw error" do
        ShopifyCLI::Git.expects(:sparse_checkout).raises(ShopifyCLI::Abort)
        assert_raises(ShopifyCLI::Abort) { subject }
      end
    end
  end
end
