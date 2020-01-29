# frozen_string_literal: true

require "test_helper"

describe ShopifyCli::ScriptModule::Domain::Script do
  let(:script_id) { "discount/myscript.ts" }
  let(:language) { "ts" }
  let(:extension_point) { Object.new }
  let(:extension_point_type) { "discount" }
  let(:script_name) { "myscript" }
  let(:code) { "int i" }
  let(:script_name) { "myscript" }
  let(:wasm_file) { Minitest::Mock.new }

  describe ".new" do
    before do
      extension_point.expects(:type).returns(extension_point_type)
    end
    subject { ShopifyCli::ScriptModule::Domain::Script.new(script_name, extension_point, language) }
    it "should construct new Script" do
      assert_equal script_id, subject.id
      assert_equal script_name, subject.name
      assert_equal extension_point, subject.extension_point
      assert_equal language, subject.language
    end
  end
end
