# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::Languages::RustProjectCreator do
  include TestHelpers::FakeFS

  let(:script_name) { "payment_filter_rs" }
  let(:language) { "rust" }
  let(:script_id) { "id" }
  let(:script) { Script::Layers::Domain::Script.new(script_id, script_name, extension_point, language) }
  let(:context) { TestHelpers::FakeContext.new }
  let(:extension_point_type) { "payment_filter" }
  let(:extension_point) { Script::Layers::Domain::ExtensionPoint.new(extension_point_type, extension_point_config) }
  let(:project_creator) do
    Script::Layers::Infrastructure::Languages::RustProjectCreator
      .new(ctx: context, extension_point: extension_point, script_name: script_name, path_to_project: script_name)
  end
  let(:extension_point_config) do
    {
      "sdks" => {
        "rust" => {
          "package": "https://github.com/Shopify/scripts-apis-rs",
          "beta": true,
        },
      },
    }
  end

  before do
    context.mkdir_p(script_name)
  end

  def system_output(msg:, success:)
    [msg, OpenStruct.new(success?: success)]
  end

  describe ".setup_dependencies" do
    subject { project_creator.setup_dependencies }

    it "should setup sparse checkout" do
      context
        .expects(:capture2e)
        .with("git init").once
        .returns(system_output(msg: "", success: true))
      context
        .expects(:capture2e)
        .with("git remote add -f origin #{extension_point.sdks.for("rust").package}")
        .once
        .returns(system_output(msg: "", success: true))
      context
        .expects(:capture2e)
        .with("git config core.sparsecheckout true")
        .once
        .returns(system_output(msg: "", success: true))
      context
        .expects(:capture2e)
        .with("echo #{extension_point.type}/default >> .git/info/sparse-checkout")
        .once
        .returns(system_output(msg: "", success: true))
      context
        .expects(:capture2e)
        .with("git pull origin main")
        .once
        .returns(system_output(msg: "", success: true))
      context.expects(:rm_rf).with(".git")
      type = extension_point.type
      source = File.join(script_name, File.join(type, "default"))
      FileUtils.expects(:copy_entry).with(source, script_name)
      context.expects(:rm_rf).with(type)
      File.expects(:read).with("Cargo.toml").returns("name = payment-filter-default")
      File.expects(:write).with("Cargo.toml", "name = #{script_name}")

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
        .with("git remote add -f origin #{extension_point.sdks.for("rust").package}").once
        .returns(system_output(msg: "Couldn't set remote origin", success: false))

      assert_raises(Script::Layers::Infrastructure::Errors::SystemCallFailureError) { subject }
    end

    it "should raise a service failure error if sparse checkout cannot be configured" do
      context.expects(:capture2e).twice.returns(system_output(msg: "", success: true))

      context
        .expects(:capture2e)
        .with("git config core.sparsecheckout true").once
        .returns(system_output(msg: "Couldn't set sparse checkout", success: false))

      assert_raises(Script::Layers::Infrastructure::Errors::SystemCallFailureError) { subject }
    end

    it "should raise a service failure error if the sparse checkout config cannot be written" do
      context.expects(:capture2e).times(3).returns(system_output(msg: "", success: true))
      context
        .expects(:capture2e)
        .with("echo #{extension_point.type}/default >> .git/info/sparse-checkout").once
        .returns(system_output(msg: "Couldn't write to the sparse checkout config", success: false))

      assert_raises(Script::Layers::Infrastructure::Errors::SystemCallFailureError) { subject }
    end

    it "raises if there is an error pulling from the remote's origin" do
      context.expects(:capture2e).times(4).returns(system_output(msg: "", success: true))
      context
        .expects(:capture2e)
        .with("git pull origin main")
        .once
        .returns(system_output(msg: "Fatal", success: false))
      assert_raises(Script::Layers::Infrastructure::Errors::SystemCallFailureError) { subject }
    end
  end
end
