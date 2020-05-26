# frozen_string_literal: true

require "project_types/script/test_helper"

module Script
  module Forms
    class ScriptFormTest < MiniTest::Test
      include TestHelpers::FakeUI

      def test_organizations_fetch_once
        UI::StrictSpinner.expects(:spin).with('Fetching organizations').yields(FakeSpinner.new).returns(true).once
        ShopifyCli::PartnersAPI::Organizations.expects(:fetch_with_app).returns(true).once
        form = ScriptForm.new(@context, [], [])
        2.times { form.send(:organizations) }
      end
    end
  end
end
