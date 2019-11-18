# frozen_string_literal: true

require "test_helper"

describe ShopifyCli::ScriptModule::Domain::ExtensionPoint do
  let(:schema) { "schema" }
  let(:type) { "discount" }
  let(:types) { "types" }
  let(:example) { "example" }
  let(:example_scripts) do
    {
      "ts" => example,
      "js" => nil,
      "json" => nil,
    }
  end

  describe ".new" do
    subject { ShopifyCli::ScriptModule::Domain::ExtensionPoint.new(type, schema, types, example) }
    it "should construct new ExtensionPoint" do
      assert_equal schema, subject.schema
      assert_equal type, subject.type
      assert_equal types, subject.sdk_types
      assert_equal example_scripts, subject.example_scripts
    end
  end
end
