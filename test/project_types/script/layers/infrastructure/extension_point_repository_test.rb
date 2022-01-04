# typed: ignore
# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::ExtensionPointRepository do
  subject { Script::Layers::Infrastructure::ExtensionPointRepository.new }

  describe ".get_extension_point" do
    describe "when the extension point is configured" do
      Script::Layers::Infrastructure::ExtensionPointRepository.new
        .send(:extension_point_configs)
        .each do |extension_point_type, _config|
        it "should be able to load the #{extension_point_type} extension point" do
          extension_point = subject.get_extension_point(extension_point_type)
          assert_equal extension_point_type, extension_point.type
          refute_empty extension_point.libraries.all
        end
      end
    end

    describe "when the extension point does not exist" do
      let(:bogus_extension) { "bogus" }

      it "should raise InvalidExtensionPointError" do
        assert_raises(Script::Layers::Domain::Errors::InvalidExtensionPointError) do
          subject.get_extension_point(bogus_extension)
        end
      end
    end
  end

  describe ".extension_point_types" do
    it "should return the ep keys" do
      subject.stubs(:extension_point_configs).returns({ "discount" => {}, "other" => {} })
      assert_equal ["discount", "other"], subject.send(:extension_point_types)
    end
  end
end
