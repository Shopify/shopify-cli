
require "test_helper"

module Extension
  module Models
    class NpmPackageTest < MiniTest::Test
      def setup
        ShopifyCLI::ProjectType.load_type(:extension)
        super
      end

      def test_has_name
        package = NpmPackage.new(**valid_attributes_with(name: "some-package-name"))
        assert_equal "some-package-name", package.name
      end

      def test_has_version
        package = NpmPackage.new(**valid_attributes_with(version: "0.0.1"))
        assert_equal "0.0.1", package.version
      end

      def test_packages_with_different_names_are_not_comparable
        package_a = NpmPackage.new(**valid_attributes_with(name: "a"))
        package_b = NpmPackage.new(**valid_attributes_with(name: "b"))
        assert_nil package_a <=> package_b
      end

      def test_packages_with_the_same_attributes_are_considered_equal
        package_a = NpmPackage.new(**valid_attributes)
        package_b = NpmPackage.new(**valid_attributes)
        assert_equal 0, package_a <=> package_b
      end

      def test_packages_can_be_ordered_by_their_version
        versions = [
          ["0.0.1", :<, "0.0.2"],
          ["0.0.1", :<, "0.1.1"],
          ["0.0.1", :<, "0.1.0"],
        ]

        versions.each do |(a, operator, b)|
          package_a = NpmPackage.new(**valid_attributes_with(version: a))
          package_b = NpmPackage.new(**valid_attributes_with(version: b))
          assert package_a.send(operator, package_b)
        end
      end

      def test_parse_name_and_version
        package_json = StringIO.new(<<~JSON)
          {
            "name": "test-package",
            "version": "1.2.3"
          }
        JSON

        package = NpmPackage.parse(package_json)
        assert_equal "test-package", package.name
        assert_equal "1.2.3", package.version
      end

      def test_parse_full_package_json
        package_json = StringIO.new(<<~JSON)
          {
            "dependencies": {
              "@shopify/checkout-ui-extensions": "^0.15.0"
            },
            "devDependencies": {
              "@shopify/shopify-cli-extensions": "latest"
            },
            "license": "MIT",
            "name": "checkout_ui_extension",
            "scripts": {
              "build": "shopify-cli-extensions build",
              "develop": "shopify-cli-extensions develop"
            }
          }
        JSON

        package = NpmPackage.parse(package_json)
        assert_equal "checkout_ui_extension", package.name
        assert_equal "shopify-cli-extensions build", package.scripts.fetch("build")
        assert_equal "shopify-cli-extensions develop", package.scripts.fetch("develop")
        assert_equal "^0.15.0", package.dependencies.fetch("@shopify/checkout-ui-extensions")
        assert_equal "latest", package.dev_dependencies.fetch("@shopify/shopify-cli-extensions")
      end

      def test_unknown_keyword_arguments_are_ignored
        assert_nothing_raised { NpmPackage.new(ignored_property: true) }
      end

      private

      def valid_attributes_with(**overrides)
        unknown_attributes = overrides.keys - valid_attributes.keys
        raise ArgumentError, "Unknown attributes: #{unknown_attributes}" if unknown_attributes.any?
        valid_attributes.merge(overrides)
      end

      def valid_attributes
        {
          name: "@shopify/argo-test",
          version: "1.2.3",
        }
      end
    end
  end
end
