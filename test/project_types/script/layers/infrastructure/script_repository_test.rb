# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::ScriptRepository do
  include TestHelpers::FakeFS

  let(:extension_point_type) { "discount" }
  let(:extension_point_config) do
    {
      "assemblyscript" => {
        "package": "@shopify/extension-point-as-fake",
        "version": "*",
        "sdk-version": "*",
      },
    }
  end
  let(:extension_point) { Script::Layers::Domain::ExtensionPoint.new(extension_point_type, extension_point_config) }
  let(:script_name) { "myscript" }
  let(:language) { "AssemblyScript" }
  let(:script_folder_base) { "/some/directory/#{script_name}" }
  let(:script_source_base) { "#{script_folder_base}/src" }
  let(:script_source_file) { "#{script_source_base}/script.#{language}" }
  let(:expected_script_id) { "src/script.#{language}" }
  let(:project) { TestHelpers::FakeProject.new }
  let(:context) { TestHelpers::FakeContext.new }
  let(:script_repository) { Script::Layers::Infrastructure::ScriptRepository.new(ctx: context) }

  before do
    context.mkdir_p(script_folder_base)
    Script::ScriptProject.stubs(:current).returns(project)
    project.directory = script_folder_base
  end

  describe ".get_script" do
    subject { script_repository.get_script(language, extension_point.type, script_name) }

    describe "when extension point is valid" do
      it "should return the requested script" do
        context.mkdir_p(script_source_base)
        File.write(script_source_file, "//script code")
        script = subject
        assert_equal expected_script_id, script.id
        assert_equal script_name, script.name
        assert_equal extension_point_type, script.extension_point_type
      end

      it "should raise ScriptNotFoundError when script source file does not exist" do
        context.mkdir_p(script_source_base)
        e = assert_raises(Script::Layers::Domain::Errors::ScriptNotFoundError) { subject }
        assert_equal script_source_file, e.script_name
      end
    end
  end
end
