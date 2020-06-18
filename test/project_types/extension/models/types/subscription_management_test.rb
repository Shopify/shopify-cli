# frozen_string_literal: true
require 'test_helper'

module Extension
  module Models
    module Types
      class SubscriptionManagementTest < MiniTest::Test
        def setup
          super
          ShopifyCli::ProjectType.load_type(:extension)
          @subscription_management = Models::Type.load_type(SubscriptionManagement::IDENTIFIER)
        end

        def test_create_uses_standard_argo_create_implementation
          directory_name = 'subscription_management'

          Features::Argo.admin
            .expects(:create)
            .with(directory_name, SubscriptionManagement::IDENTIFIER, @context)
            .once

          @subscription_management.create(directory_name, @context)
        end

        def test_config_uses_standard_argo_config_implementation
          Features::Argo.admin.expects(:config).with(@context).once

          @subscription_management.config(@context)
        end
      end
    end
  end
end
