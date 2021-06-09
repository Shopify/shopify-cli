# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::ScriptApiRepository do
  subject { Script::Layers::Infrastructure::ScriptApiRepository.new }

  describe ".get" do
    describe "when the extension point is configured" do
      Script::Layers::Infrastructure::ScriptApiRepository.new
        .send(:script_api_configs)
        .each do |script_api_type, _config|
        it "should be able to load the #{script_api_type} extension point" do
          script_api = subject.get(script_api_type)
          assert_equal script_api_type, script_api.type
          refute_nil script_api.sdks.assemblyscript.package
        end
      end
    end

    describe "when the extension point does not exist" do
      let(:bogus_extension) { "bogus" }

      it "should raise InvalidScriptApiError" do
        assert_raises(Script::Layers::Domain::Errors::InvalidScriptApiError) do
          subject.get(bogus_extension)
        end
      end
    end
  end

  describe ".all_types" do
    it "should return the ep keys" do
      subject.stubs(:script_api_configs).returns({ "discount" => {}, "other" => {} })
      assert_equal ["discount", "other"], subject.send(:all_types)
    end
  end
end
