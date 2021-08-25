# frozen_string_literal: true

require "project_types/script/test_helper"

class GenericProjectCreator < Script::Layers::Infrastructure::Languages::ProjectCreator
  def self.config_file
    "generic.json"
  end
end

describe Script::Layers::Infrastructure::Languages::ProjectCreator do
  include TestHelpers::FakeFS

  let(:context) { TestHelpers::FakeContext.new }
  let(:language) { "assemblyscript" }

  let(:domain) { "fake-domain" }
  let(:extension_point_type) { "fake-ep-type" }
  let(:repo) { "fake-repo" }

  let(:project_name) { "myscript" }
  let(:branch) { "fake-branch" }

  # TODO: Fails with any other path
  let(:path) { "." }

  # TODO: fakeFS doesn't seem to support copy_entry properly so we need add a trailing /.
  let(:sparse_checkout_set_path) { "packages/#{domain}/samples/#{extension_point_type}/." }

  let(:source) { File.join(path, sparse_checkout_set_path) }

  let(:project_creator) do
    GenericProjectCreator.new(
      ctx: context,
      domain: domain,
      type: extension_point_type,
      repo: repo,
      project_name: project_name,
      path_to_project: path,
      branch: branch,
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
          domain: domain,
          type: extension_point_type,
          repo: repo,
          project_name: project_name,
          path_to_project: path,
          branch: branch,
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
        ShopifyCli::Git
          .expects(:sparse_checkout)
          .with(
            repo,
            project_creator.sparse_checkout_set_path,
            branch,
            context
          )
          .once

        # setup the directory and files that sparse-checkout would produce
        FileUtils.mkdir_p(source)
        FileUtils.mkdir_p(".git")
        File.write(
          File.join(
            source,
            GenericProjectCreator.config_file
          ),
          "#{extension_point_type}-default"
        )

        assert(Dir.exist?(source))
        assert(Dir.exist?(".git"))
        assert(File.exist?(File.join(source, GenericProjectCreator.config_file)))
      end

      describe "when content in the directory is correct" do
        it "should sucessfully setup dependencies" do
          subject

          # clean
          # old directory deleted
          refute(Dir.exist?(source))

          # config file copied up
          assert(File.exist?(GenericProjectCreator.config_file))

          # directories deleted
          refute(Dir.exist?("packages"))
          refute(Dir.exist?(".git"))

          # update_project_name
          # config file contents reworked
          assert_equal(File.read(GenericProjectCreator.config_file), project_name)
        end
      end

      describe "when content is wrong" do
        # assert_raises
      end
    end

    describe "when Git sparse checkout throws error" do
      it "shouuld also throw error" do
        ShopifyCli::Git.expects(:sparse_checkout).raises(ShopifyCli::Abort)
        assert_raises(ShopifyCli::Abort) { subject }
      end
    end
  end
end
