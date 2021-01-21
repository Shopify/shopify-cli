# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Domain::PushPackage do
  let(:extension_point_type) { "discount" }
  let(:script_id) { 'id' }
  let(:script_name) { "foo_script" }
  let(:script) do
    Script::Layers::Domain::Script.new(script_id, script_name, extension_point_type, "AssemblyScript")
  end

  let(:api_key) { "fake_key" }
  let(:force) { false }
  let(:script_content) { "(module)" }
  let(:compiled_type) { "wasm" }
  let(:push_package) do
    Script::Layers::Domain::PushPackage.new(id, script, script_content, compiled_type)
  end
  let(:script_service) { Minitest::Mock.new }
  let(:id) { "push_package_id" }

  describe ".new" do
    subject { push_package }

    it "should construct new PushPackage" do
      assert_equal id, subject.id
      assert_equal script_content, subject.script_content
    end
  end

  describe ".push" do
    subject { push_package.push(script_service, api_key, force) }

    it "should open write to build file and push" do
      script_service.expect(:push, nil) do |kwargs|
        kwargs[:extension_point_type] == extension_point_type &&
          kwargs[:script_name] == script_name &&
          kwargs[:script_content] == script_content &&
          kwargs[:compiled_type] == compiled_type &&
          kwargs[:api_key] == api_key
      end
      subject
    end
  end
end
