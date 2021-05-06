# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Features
    class ArgoServeTest < MiniTest::Test
      include TestHelpers::Partners
      include TestHelpers::FakeUI

      ARGO_ADMIN_TEMPLATE = "https://github.com/Shopify/argo-admin.git"
      ARGO_CHECKOUT_TEMPLATE = "https://github.com/Shopify/argo-checkout.git"

      def setup
        super
        @api_key = "123abc"
        @registration_uuid = "dev-123"
        @argo_version = "0.9.4"
        ShopifyCli::ProjectType.load_type("extension")
      end

      def test_extensions_that_require_version_have_argo_version_command_line_argument
        stub_argo_enabled_shop
        dummy_handler = build_dummy_specification_handler(
          renderer_package_version: @argo_version,
          specification: admin_specification
        )

        ShopifyCli::JsSystem.any_instance
          .expects(:call)
          .with do |args|
            assert_includes args.fetch(:yarn), "--argoVersion=#{@argo_version}"
            assert_includes args.fetch(:npm), "--argoVersion=#{@argo_version}"
          end
          .returns(true)
          .once
        ArgoServe.new(specification_handler: dummy_handler, context: @context).call
      end

      def test_extension_versions_that_do_not_require_argo_version_do_not_have_argo_version_command_line_arg
        stub_argo_enabled_shop
        dummy_handler = build_dummy_specification_handler(
          renderer_package_version: @argo_version,
          specification: checkout_specification
        )

        ShopifyCli::JsSystem.any_instance
          .expects(:call)
          .with do |args|
            refute_includes(args.fetch(:yarn), "--argoVersion=#{@argo_version}")
            refute_includes(args.fetch(:npm), "--argoVersion=#{@argo_version}")
          end
          .returns(true)
          .once
        ArgoServe.new(specification_handler: dummy_handler, context: @context).call
      end

      def test_extension_versions_that_support_uuid_have_uuid_command_line_argument
        skip("Passing the a UUID to the Argo Webpack server is currently not supported")

        stub_argo_enabled_shop
        dummy_handler = build_dummy_specification_handler(
          renderer_package_version: @argo_version,
          specification: admin_specification
        )

        ShopifyCli::JsSystem.any_instance
          .expects(:call)
          .with do |args|
            assert_includes args.fetch(:yarn), "--uuid=#{@registration_uuid}"
            assert_includes args.fetch(:npm), "--uuid=#{@registration_uuid}"
          end
          .returns(true)
          .once
        ArgoServe.new(specification_handler: dummy_handler, context: @context).call
      end

      def test_extension_versions_that_do_not_support_uuid_do_not_have_uuid_command_line_argument
        stub_argo_enabled_shop
        unsupported_argo = "0.9.2"
        dummy_handler = build_dummy_specification_handler(
          renderer_package_version: unsupported_argo,
          specification: admin_specification
        )

        ShopifyCli::JsSystem.any_instance
          .expects(:call)
          .with do |args|
            refute_includes(args.fetch(:yarn), "--uuid=#{@registration_uuid}")
            refute_includes(args.fetch(:npm), "--uuid=#{@registration_uuid}")
          end
          .returns(true)
          .once
        ArgoServe.new(specification_handler: dummy_handler, context: @context).call
      end

      private

      def mock_specification(surface:, git_template:, renderer_package_name:, required_fields: [], betas: [])
        {
          identifier: "test",
          features: {
            argo: {
              surface: surface,
              git_template: git_template,
              renderer_package_name: renderer_package_name,
              required_fields: required_fields,
              required_shop_beta_flags: betas,
            },
          },
        }
      end

      def checkout_specification
        mock_specification(surface: "checkout", git_template: ARGO_CHECKOUT_TEMPLATE,
renderer_package_name: "@shopify/argo-checkout")
      end

      def admin_specification
        mock_specification(surface: "admin", git_template: ARGO_ADMIN_TEMPLATE,
renderer_package_name: "@shopify/argo-admin")
      end

      def stub_argo_enabled_shop(api_key: @api_key, registration_uuid: @registration_uuid, argo_version: @argo_version)
        _ = argo_version
        ShopifyCli::Shopifolk.stubs(:check).returns(true)
        ShopifyCli::Feature.stubs(:enabled?).with(:argo_admin_beta).returns(true)
        ShopifyCli::Tasks::EnsureEnv.stubs(:call)
        ShopifyCli::Tasks::EnsureDevStore.stubs(:call)
        ExtensionTestHelpers.fake_extension_project(with_mocks: true, api_key: api_key,
registration_uuid: registration_uuid)
      end

      def build_dummy_specification_handler(renderer_package_version:, specification:)
        dummy_specification = Extension::Models::Specification.new(specification)
        dummy_handler = Extension::Models::SpecificationHandlers::Default.new(dummy_specification)
        dummy_handler.stubs(:renderer_package).returns(
          Extension::Features::ArgoRendererPackage.new(
            package_name: dummy_specification.features.argo.renderer_package_name,
            version: renderer_package_version
          )
        )
        dummy_handler
      end
    end
  end
end
