# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::Languages::AssemblyScriptProjectCreator do
  include TestHelpers::FakeFS

  let(:script_name) { "myscript" }
  let(:language) { "AssemblyScript" }
  let(:script_id) { "id" }
  let(:context) { TestHelpers::FakeContext.new }
  let(:extension_point_type) { "payment_methods" }
  let(:extension_point) { Script::Layers::Domain::ExtensionPoint.new(extension_point_type, extension_point_config) }
  let(:project_creator) do
    Script::Layers::Infrastructure::Languages::AssemblyScriptProjectCreator
      .new(ctx: context, extension_point: extension_point, script_name: script_name, path_to_project: script_name)
  end
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
  let(:fake_capture2e_response) { [nil, OpenStruct.new(success?: true)] }

  before do
    context.mkdir_p(script_name)
  end

  def system_output(msg:, success:)
    [msg, OpenStruct.new(success?: success)]
  end

  describe ".setup_dependencies" do
    subject { project_creator.setup_dependencies }

    it "should setup sparse checkout" do
      # sparse checkout
      context
        .expects(:capture2e)
        .with("git init").once
        .returns(system_output(msg: "", success: true))
      context
        .expects(:capture2e)
        .with("git remote add -f origin #{extension_point.sdks.assemblyscript.repo}")
        .once
        .returns(system_output(msg: "", success: true))
      context
        .expects(:capture2e)
        .with("git config core.sparsecheckout true")
        .once
        .returns(system_output(msg: "", success: true))
      context
        .expects(:capture2e)
        .with("git sparse-checkout set #{project_creator.sparse_checkout_set_path}")
        .once
        .returns(system_output(msg: "", success: true))
      context
        .expects(:capture2e)
        .with("git pull origin #{project_creator.origin_branch}")
        .once
        .returns(system_output(msg: "", success: true))

      # npmrc generation
      context
        .expects(:capture2e)
        .with("npm --userconfig ./.npmrc config set @shopify:registry https://registry.npmjs.com")
        .returns(fake_capture2e_response)
      context
        .expects(:capture2e)
        .then.with("npm --userconfig ./.npmrc config set engine-strict true")
        .returns(fake_capture2e_response)

      # moving files up to project root
      source = File.join(project_creator.path_to_project, project_creator.sparse_checkout_set_path)
      FileUtils.expects(:copy_entry).with(source, project_creator.path_to_project)

      # confirm package.json
      File.expects(:read).with("package.json").returns("name: payment-methods-default")
      File.expects(:write).with("package.json", "name: #{script_name}")

      # clean-up git files
      context.expects(:rm_rf).with(".git")
      context.expects(:rm_rf).with("packages")

      subject
    end

    it "should raise a service failure error if the git repository cannot be iniitialized" do
      context
        .expects(:capture2e)
        .with("git init").once
        .returns(system_output(msg: "Couldn't initialize git repository", success: false))

      assert_raises(Script::Layers::Infrastructure::Errors::SystemCallFailureError) { subject }
    end

    it "should raise a service failure error if the git remote cannot be configured" do
      context.expects(:capture2e).once.returns(system_output(msg: "", success: true))

      context
        .expects(:capture2e)
        .with("git remote add -f origin #{extension_point.sdks.assemblyscript.repo}").once
        .returns(system_output(msg: "Couldn't set remote origin", success: false))

      assert_raises(Script::Layers::Infrastructure::Errors::SystemCallFailureError) { subject }
    end

    it "should raise a service failure error if sparse checkout cannot be enabled" do
      context.expects(:capture2e).twice.returns(system_output(msg: "", success: true))

      context
        .expects(:capture2e)
        .with("git config core.sparsecheckout true").once
        .returns(system_output(msg: "Couldn't enable sparse checkout", success: false))

      assert_raises(Script::Layers::Infrastructure::Errors::SystemCallFailureError) { subject }
    end

    it "should raise a service failure error if sparse checkout cannot be set" do
      context.expects(:capture2e).times(3).returns(system_output(msg: "", success: true))

      context
        .expects(:capture2e)
        .with("git sparse-checkout set #{project_creator.sparse_checkout_set_path}").once
        .returns(system_output(msg: "Couldn't set sparse checkout", success: false))

      assert_raises(Script::Layers::Infrastructure::Errors::SystemCallFailureError) { subject }
    end

    it "raises if there is an error pulling from the remote's origin" do
      context.expects(:capture2e).times(4).returns(system_output(msg: "", success: true))
      context
        .expects(:capture2e)
        .with("git pull origin #{project_creator.origin_branch}")
        .once
        .returns(system_output(msg: "Fatal", success: false))
      assert_raises(Script::Layers::Infrastructure::Errors::SystemCallFailureError) { subject }
    end
  end
end
