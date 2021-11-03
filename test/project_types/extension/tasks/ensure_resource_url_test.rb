# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Tasks
    class EnsureResourceUrlTest < MiniTest::Test
      def setup
        ShopifyCLI::ProjectType.load_type(:extension)
        super
      end

      def test_builds_resource_url_if_necessary
        specification_handler = ExtensionTestHelpers.test_specifications["TEST_EXTENSION"]

        ExtensionProject.expects(:update_env_file).with(
          has_entries(context: anything, resource_url: "/generated")
        )

        Tasks::EnsureResourceUrl.call(
          context: @context,
          specification_handler: specification_handler.tap do |handler|
            handler.expects(:build_resource_url).returns("/generated")
          end
        )
      end
    end
  end
end
