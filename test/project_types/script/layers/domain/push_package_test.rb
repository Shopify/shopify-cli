# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Domain::PushPackage do
  let(:uuid) { "uuid" }
  let(:extension_point_type) { "discount" }
  let(:script_id) { "id" }
  let(:script_config) { { "version" => "1" } }
  let(:project_title) { "title" }
  let(:project_description) { "description" }
  let(:api_key) { "fake_key" }
  let(:force) { false }
  let(:script_content) { "(module)" }
  let(:metadata) { Script::Layers::Domain::Metadata.new("1", "0", true) }
  let(:library_language) { "assemblyscript" }
  let(:library_version) { "1.0.0" }
  let(:library) do
    {
      language: library_language,
      version: library_version,
    }
  end
  let(:push_package) do
    Script::Layers::Domain::PushPackage.new(
      id: id,
      uuid: uuid,
      extension_point_type: extension_point_type,
      title: project_title,
      description: project_description,
      script_config: script_config,
      script_content: script_content,
      metadata: metadata,
      library: library
    )
  end
  let(:script_service) { Minitest::Mock.new }
  let(:id) { "push_package_id" }

  describe ".new" do
    subject { push_package }

    it "should construct new PushPackage" do
      assert_equal id, subject.id
      assert_equal uuid, subject.uuid
      assert_equal extension_point_type, subject.extension_point_type
      assert_equal project_title, subject.title
      assert_equal project_description, subject.description
      assert_equal script_config, subject.script_config
      assert_equal script_content, subject.script_content
      assert_equal metadata, subject.metadata
      assert_equal library, subject.library
    end
  end
end
