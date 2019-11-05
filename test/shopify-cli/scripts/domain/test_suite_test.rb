# frozen_string_literal: true

require "test_helper"

describe ShopifyCli::ScriptModule::Domain::TestSuite do
  let(:id) { "#{ShopifyCli::ScriptModule::Infrastructure::Repository::SOURCE_PATH}/discount/myscript/myscript.spec.ts" }
  let(:language) { "ts" }
  let(:extension_point_type) { "discount" }
  let(:script_name) { "myscript" }
  let(:script) { ShopifyCli::ScriptModule::Domain::Script.new(script_name, extension_point_type, language, "schema") }

  describe ".new" do
    subject { ShopifyCli::ScriptModule::Domain::TestSuite.new(id, script) }

    it "should construct new Script" do
      suite = subject
      assert_equal id, suite.id
      assert_equal script, suite.script
    end
  end
end
