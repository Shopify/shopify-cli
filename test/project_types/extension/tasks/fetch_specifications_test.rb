require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Tasks
    class FetchSpecificationsTest < MiniTest::Test
      include TestHelpers
      include TestHelpers::FakeUI
      include TestHelpers::Partners
      include ExtensionTestHelpers::Stubs::FetchSpecifications

      def setup
        super
        ShopifyCLI::ProjectType.load_type(:extension)
      end

      def test_request
        stub_fetch_specifications(api_key: "1234")

        FetchSpecifications.call(context: FakeContext.new, api_key: "1234").tap do |result|
          assert_predicate(result, :success?)
          result.value.tap do |specifications|
            assert_kind_of(Array, specifications)
            assert specifications.all? { |s| s.is_a?(Hash) }
          end
        end
      end
    end
  end
end
