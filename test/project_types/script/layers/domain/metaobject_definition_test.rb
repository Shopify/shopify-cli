# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Domain::MetaobjectDefinition do
  let(:content) { { "key" => "value" } }
  let(:filename) { "function.metaobject.yml" }

  subject { Script::Layers::Domain::MetaobjectDefinition.new(content: content, filename: filename) }

  describe "#initialize" do
    it "constructs a MetaobjectDefinition" do
      assert_equal(content, subject.content)
      assert_equal(filename, subject.filename)
    end
  end
end
