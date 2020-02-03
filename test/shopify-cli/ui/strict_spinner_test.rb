# frozen_string_literal: true

require "test_helper"

describe ShopifyCli::UI::StrictSpinner do
  describe ".spin" do
    let(:title) { 'title' }

    describe "when an error is thrown in the block" do
      subject do
        ShopifyCli::UI::StrictSpinner.spin(title, auto_debrief: false) do
          raise(StandardError, "some err")
        end
      end

      it "should abort" do
        assert_raises(StandardError, "some err") { subject }
      end
    end

    describe "when the block runs successfully" do
      subject do
        ShopifyCli::UI::StrictSpinner.spin(title, auto_debrief: false) do
          true
        end
      end

      it "should do nothing" do
        assert_nothing_raised { subject }
      end
    end
  end
end
