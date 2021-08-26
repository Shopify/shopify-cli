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

  # This is fixed now.  The problem was line 51 and 71 in project_creator, see it needs to read 
  # path_to_project/package.json (after you copied the stuff over from source to path_to_project).
  # I wonder if it worked for you before because you have a package.json locally in your .?  
  let(:path) { "project_path" }

  # TODO: fakeFS doesn't seem to support copy_entry properly so we need add a trailing /.
  let(:sparse_checkout_set_path) { "packages/#{domain}/samples/#{extension_point_type}" }

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
      end

      describe "when content in the directory is correct" do
        # moving it here, since the failure case doesn't contain this file.
        before do
          File.write(
            File.join(
              source,
              GenericProjectCreator.config_file
            ),
            "#{extension_point_type}-default"
          )
        end

        it "should sucessfully setup dependencies" do
          # You really need to use expects on context here, and not call context.rm_rf directly.
          context.expects(:rm_rf).with("packages")
          context.expects(:rm_rf).with(".git")

          subject

          # clean
          # old directory deleted
          # This isn't needed, because we are really removing packages, and source is a child dir in packages.
          # refute(Dir.exist?(source))

          # config file copied up (NOTE: needs to check that the file is in path/config_file)
          config_file = File.join(path, GenericProjectCreator.config_file)
          assert(File.exist?(config_file))

          # directories deleted
          # this isn't needed, since we are expecting context.rm_rf
          # refute(Dir.exist?("packages"))
          # refute(Dir.exist?(".git"))

          # update_project_name
          # config file contents reworked
          assert_equal(File.read(config_file), project_name)
        end
      end

      describe "when the expected config.json is missing" do
        # You can try this by simply checking out the master branch, and you will see stacktrace like:
        # /Users/erinren/src/github.com/Shopify/shopify-cli/lib/project_types/script/layers/infrastructure/languages/project_creator.rb:67:in `read': No such file or directory @ rb_sysopen - package.json (Errno::ENOENT)
        # Unit tests really allows you precisely control all the failure scenarios to make sure your code is robust!
        it "should raise InvalidProjectError error" do
          assert_raises(Script::Layers::Infrastructure::Errors::InvalidBuildScriptError) { subject }
        end
      end

      # Similarly, I think if the content is not as expected, we should fail?
      # In the end, I decided that this test isn't useful, since there is no good way to check
      # the content of the file was valid.  I left it in to show you my thought process when writing unit test.
      # describe "when content is wrong" do
      #   before do
      #     File.write(
      #       File.join(
      #         source,
      #         GenericProjectCreator.config_file
      #       ),
      #       "something is wrong"
      #     )
      #   end
      #   it "should raise InvalidProjectError error" do
      #     assert_raises(Script::Layers::Infrastructure::Errors::InvalidBuildScriptError) { subject }
      #   end
      # end
    end

    describe "when Git sparse checkout throws error" do
      it "shouuld also throw error" do
        ShopifyCli::Git.expects(:sparse_checkout).raises(ShopifyCli::Abort)
        assert_raises(ShopifyCli::Abort) { subject }
      end
    end
  end
end
