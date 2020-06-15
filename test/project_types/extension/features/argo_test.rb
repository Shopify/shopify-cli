# frozen_string_literal: true
require 'test_helper'
require 'project_types/extension/extension_test_helpers'
require 'base64'
require 'pathname'

module Extension
  module Features
    class ArgoTest < MiniTest::Test
      include TestHelpers::FakeUI
      include ExtensionTestHelpers::Stubs::ArgoScript

      def setup
        super
        ShopifyCli::ProjectType.load_type(:extension)

        @git_template = 'https://www.github.com/fake_template.git'
        @argo = Argo.new(setup: Features::ArgoSetup.new(git_template: @git_template))
        @identifier = 'FAKE_ARGO_TYPE'
        @directory = 'fake_directory'
      end

      def test_config_aborts_with_error_if_script_file_doesnt_exist
        error = assert_raises ShopifyCli::Abort do
          @argo.config(@context)
        end

        assert error.message.include?(@context.message('features.argo.missing_file_error'))
      end

      def test_config_aborts_with_error_if_script_serialization_fails
        File.stubs(:exists?).returns(true)
        Base64.stubs(:strict_encode64).raises(IOError)

        error = assert_raises(ShopifyCli::Abort) { @argo.config(@context) }
        assert error.message.include?(@context.message('features.argo.script_prepare_error'))
      end

      def test_config_aborts_with_error_if_file_read_fails
        File.stubs(:exists?).returns(true)
        File.any_instance.stubs(:read).raises(IOError)

        error = assert_raises(ShopifyCli::Abort) { @argo.config(@context) }
        assert error.message.include?(@context.message('features.argo.script_prepare_error'))
      end

      def test_config_encodes_script_into_context_if_it_exists
        with_stubbed_script(@context, Argo::SCRIPT_PATH) do
          config = @argo.config(@context)

          assert_equal [:serialized_script], config.keys
          assert_equal Base64.strict_encode64(TEMPLATE_SCRIPT.chomp), config[:serialized_script]
        end
      end

      def test_admin_method_returns_an_argo_extension_with_the_subscription_management_template
        git_admin_template = 'https://github.com/Shopify/shopify-app-extension-template.git'.freeze
        argo = Argo.admin
        assert_equal(argo.setup.git_template, git_admin_template)
      end

      def test_checkout_method_returns_an_argo_extension_with_the_checkout_post_purchase_template
        git_checkout_template = 'https://github.com/Shopify/argo-checkout-template.git'.freeze
        argo = Argo.checkout
        assert_equal(argo.setup.git_template, git_checkout_template)
      end
    end
  end
end
