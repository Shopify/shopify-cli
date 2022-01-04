# typed: ignore
require "test_helper"

module Extension
  module Tasks
    class FindPackageFromJsonTest < MiniTest::Test
      def setup
        super
        ShopifyCLI::ProjectType.load_type(:extension)
      end

      def test_package_is_returned_if_found
        File.expects(:read).returns(mock_package_json)
        package = Tasks::FindPackageFromJson.call("@shopify/admin-ui-extensions", context: @context)
        assert_equal("@shopify/admin-ui-extensions", package.name)
        assert_equal("0.14.0", package.version)
        assert_instance_of(Models::NpmPackage, package)
      end

      def test_error_is_raised_if_package_not_found
        error = assert_raises ShopifyCLI::Abort do
          Tasks::FindPackageFromJson.call("does-not-exist", context: @context)
        end

        assert_instance_of(CLI::Kit::Abort, error)
        assert_includes error.message, "Unable to find module does-not-exist"
      end

      private

      def mock_package_json
        <<~JSON
          {
            "name": "@shopify/admin-ui-extensions",
            "version": "0.14.0"
          }
        JSON
      end
    end
  end
end
