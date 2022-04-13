# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::Languages::ProjectCreator do
  include TestHelpers::FakeFS

  let(:context) { TestHelpers::FakeContext.new }
  let(:language) { "typescript" }

  let(:domain) { "fake-domain" }
  let(:extension_point_type) { "fake-ep-type" }
  let(:project_name) { "myscript" }

  let(:path) { "project_path" }

  let(:sparse_checkout_details) do
    Script::Layers::Infrastructure::SparseCheckoutDetails.new(
      repo: "fake-repo",
      branch: "fake-branch",
      path: "packages/#{domain}/samples/#{extension_point_type}",
      input_queries_enabled: false,
    )
  end

  let(:source) { File.join(path, sparse_checkout_details.path) }

  let(:project_creator) do
    Script::Layers::Infrastructure::Languages::ProjectCreator.new(
      ctx: context,
      type: extension_point_type,
      project_name: project_name,
      path_to_project: path,
      sparse_checkout_details: sparse_checkout_details,
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
          sparse_checkout_details: sparse_checkout_details,
        )
    end

    describe "when the script language is typescript" do
      it "should return the TypeScriptProjectCreator" do
        assert_instance_of(Script::Layers::Infrastructure::Languages::TypeScriptProjectCreator, subject)
      end
    end

    describe "when the script language is wasm" do
      let(:language) { "wasm" }

      it "should return the WasmProjectCreator" do
        assert_instance_of(Script::Layers::Infrastructure::Languages::WasmProjectCreator, subject)
      end
    end

    describe "when the script language doesn't match an entry in the registry" do
      let(:language) { "ArnoldC" }

      it "should return a wasm project creator" do
        assert_instance_of(Script::Layers::Infrastructure::Languages::WasmProjectCreator, subject)
      end
    end
  end

  describe ".setup_dependencies" do
    subject { project_creator.setup_dependencies }

    describe "when Git sparse checkout is successful" do
      before do
        sparse_checkout_details.expects(:setup).with(context).once

        # setup the directory and files that sparse-checkout would produce
        FileUtils.mkdir_p(source)
        FileUtils.mkdir_p(".git")
      end

      it "should sucessfully setup dependencies" do
        context.expects(:rm_rf).with(project_creator.sparse_checkout_details.path.split("/")[0])
        context.expects(:rm_rf).with(".git")

        subject
      end
    end

    describe "when Git sparse checkout throws error" do
      it "should also throw error" do
        sparse_checkout_details.expects(:setup).raises(ShopifyCLI::Abort)
        assert_raises(ShopifyCLI::Abort) { subject }
      end
    end
  end
end
