# frozen_string_literal: true

require "test_helper"

describe ShopifyCli::ScriptModule::Domain::TestSuite do
  let(:id) do
    "#{format(ShopifyCli::ScriptModule::Infrastructure::Repository::FOLDER_PATH_TEMPLATE, script_name: script_name)}"\
    "/discount/myscript/myscript.spec.ts"
  end
  let(:language) { "ts" }
  let(:extension_point_type) { "discount" }
  let(:script_name) { "myscript" }
  let(:script) { ShopifyCli::ScriptModule::Domain::Script.new(script_name, extension_point_type, language) }

  describe ".new" do
    subject { ShopifyCli::ScriptModule::Domain::TestSuite.new(id, script) }

    it "should construct new Script" do
      suite = subject
      assert_equal id, suite.id
      assert_equal script, suite.script
    end
  end
end
