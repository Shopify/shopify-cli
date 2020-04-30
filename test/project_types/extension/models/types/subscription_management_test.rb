# frozen_string_literal: true
require 'test_helper'
require 'project_types/extension/extension_test_helpers'
require 'base64'

module Extension
  module Models
    module Types
      class SubscriptionManagementTest < MiniTest::Test
        include TestHelpers::FakeUI
        include ExtensionTestHelpers::TempProjectSetup
        include ExtensionTestHelpers::Stubs::ArgoScript

        def setup
          super
          setup_temp_project
          @subscription_management = Models::Type.load_type(SubscriptionManagement::IDENTIFIER)
        end

        def test_aborts_with_error_if_script_file_doesnt_exist
          error = assert_raises ShopifyCli::Abort do
            @subscription_management.config(@context)
          end

          assert error.message.include?(@subscription_management.get_content(:missing_file_error))
        end

        def test_aborts_with_error_if_script_serialization_fails
          File.stubs(:exists?).returns(true)
          Base64.stubs(:strict_encode64).raises(IOError)

          error = assert_raises(ShopifyCli::Abort) { @subscription_management.config(@context) }
          assert error.message.include?(@subscription_management.get_content(:script_prepare_error))
        end

        def test_aborts_with_error_if_file_read_fails
          File.stubs(:exists?).returns(true)
          File.any_instance.stubs(:read).raises(IOError)

          error = assert_raises(ShopifyCli::Abort) { @subscription_management.config(@context) }
          assert error.message.include?(@subscription_management.get_content(:script_prepare_error))
        end

        def test_encodes_script_into_context_if_it_exists
          with_stubbed_script(@context, SubscriptionManagement::SCRIPT_PATH) do
            config = @subscription_management.config(@context)

            assert_equal [:serialized_script], config.keys
            assert_equal Base64.strict_encode64(TEMPLATE_SCRIPT.chomp), config[:serialized_script]
          end
        end
      end
    end
  end
end
