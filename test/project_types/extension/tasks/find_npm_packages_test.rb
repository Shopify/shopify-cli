require "test_helper"

module Extension
  module Tasks
    class FindNpmPackagesTest < MiniTest::Test
      def setup
        super
        ShopifyCli::ProjectType.load_type(:extension)
      end

      def test_finds_single_package
        result = find_all_npm_packages("@shopify/argo-post-purchase")
        assert_predicate(result, :success?)
        result.value.first.tap do |package|
          assert_equal "@shopify/argo-post-purchase", package.name
          assert_equal "0.9.1", package.version
        end
      end

      def test_finds_multiple_packages
        result = find_all_npm_packages(
          "@shopify/argo-post-purchase",
          "@shopify/argo-post-purchase-react"
        )

        assert_predicate(result, :success?)
        result.value.tap do |packages|
          assert_equal 2, packages.count

          packages
            .find { |p| p.name == "@shopify/argo-post-purchase" }
            .yield_self { |p| assert_equal "0.9.1", p.version }

          packages
            .find { |p| p.name == "@shopify/argo-post-purchase-react" }
            .yield_self { |p| assert_equal "0.9.3", p.version }
        end
      end

      def test_fails_if_at_least_one_package_cannot_be_found
        result = find_all_npm_packages(
          "@shopify/argo-post-purchase",
          "@shopify/does-not-exist"
        )

        assert_predicate(result, :failure?)
        result.error.tap do |error|
          assert_kind_of(PackageNotFound, error)
          assert_equal "Missing packages: @shopify/does-not-exist", error.message
        end
      end

      def test_finding_at_least_one_package
        result = find_at_least_one_npm_package(
          "@shopify/argo-post-purchase",
          "@shopify/does-not-exist"
        )

        assert_predicate(result, :success?)
        result.value.tap do |packages|
          assert_equal 1, packages.count

          packages
            .find { |p| p.name == "@shopify/argo-post-purchase" }
            .yield_self { |p| assert_equal "0.9.1", p.version }
        end
      end

      def test_finding_at_least_one_package_fails_if_no_package_can_be_found
        result = find_at_least_one_npm_package(
          "@shopify/does-not-exist",
          "@shopify/does-not-exist-either"
        )

        assert_predicate(result, :failure?)
        result.error.tap do |error|
          assert_kind_of(PackageNotFound, error)
          assert_equal "Expected at least one of the following packages: " \
            "@shopify/does-not-exist, @shopify/does-not-exist-either", error.message
        end
      end

      private

      def find_all_npm_packages(*names)
        FindNpmPackages.all(*names, js_system: js_system)
      end

      def find_at_least_one_npm_package(*names)
        FindNpmPackages.at_least_one_of(*names, js_system: js_system)
      end

      def js_system
        ShopifyCli::JsSystem.new(ctx: @context).tap do |js_system|
          success = mock(success?: true)
          js_system.expects(:call).returns([yarn_output, nil, success])
        end
      end

      def yarn_output
        <<~YARN
          argo-checkout-template@0.1.0 /Users/t6d/src/local/cli-specification-experiment/2021-04-30_post_purchase_test
          ├── @shopify/argo-post-purchase-react@0.9.3
          ├── @shopify/argo-post-purchase@0.9.1
          └── react@17.0.1
        YARN
      end
    end
  end
end
