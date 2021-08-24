# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::Languages::ProjectCreator do
  include TestHelpers::FakeFS
  
  let(:context) { TestHelpers::FakeContext.new }
  let(:language) { "generic" }

  let(:domain) { "fake-domain" }
  let(:extension_point_type) { "fake-ep-type" }
  let(:repo) { "fake-repo" }

  let(:script_name) { "myscript" }
  let(:branch) { "fake-branch" }
  let(:path) {"/path"}

  let(:sparse_checkout_set_path) { "packages/#{domain}/samples/#{extension_point_type}" }

  let(:project_creator) do
    Script::Layers::Infrastructure::Languages::ProjectCreator.for(
      ctx: context,
      language: language,
      domain: domain,
      type: extension_point_type,
      repo: repo,
      script_name: script_name,
      path_to_project: path,
      branch: branch,
      sparse_checkout_set_path: sparse_checkout_set_path,
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
          domain: domain,
          type: extension_point_type,
          repo: repo,
          script_name: script_name,
          path_to_project: path,
          branch: branch,
          sparse_checkout_set_path: sparse_checkout_set_path,
        )
    end

    describe "when the script language does match an entry in the registry" do
      it "should return the entry from the registry" do
        assert_instance_of(Script::Layers::Infrastructure::Languages::GenericProjectCreator, subject)
      end
    end

    describe "when the script language doesn't match an entry in the registry" do
      let(:language) { "ArnoldC" }

      it "should raise dependency not supported error" do
        assert_raises(Script::Layers::Infrastructure::Errors::ProjectCreatorNotFoundError) { subject }
      end
    end
  end

  describe "setup_dependencies" do
    subject { project_creator.setup_dependencies }

    it "should setup dependencies" do
      # setup_sparse_checkout
      ShopifyCli::Git
        .expects(:sparse_checkout)
        .with(
          repo,
          project_creator.sparse_checkout_set_path,
          branch,
          context
        )
        .once

      # clean
      source = File.join(project_creator.path_to_project, project_creator.sparse_checkout_set_path)
      FileUtils.expects(:copy_entry).with(source, project_creator.path_to_project)

      # set_script_name
      File.expects(:read).with("package.json").returns("name = #{extension_point_type.gsub("_", "-")}-default")
      File.expects(:write).with("package.json", "name = #{script_name}")

      subject
    end
  end
end
