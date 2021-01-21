# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Domain::Script do
  let(:script_id) { "discount/myscript.ts" }
  let(:language) { "AssemblyScript" }
  let(:extension_point_type) { "discount" }
  let(:script_name) { "myscript" }

  describe ".new" do
    subject { Script::Layers::Domain::Script.new(script_id, script_name, extension_point_type, language) }
    it "should construct new Script" do
      assert_equal script_id, subject.id
      assert_equal script_name, subject.name
      assert_equal extension_point_type, subject.extension_point_type
      assert_equal language, subject.language
    end
  end
end
