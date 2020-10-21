# frozen_string_literal: true
require 'test_helper'
require 'project_types/extension/extension_test_helpers'

module Extension
  module Features
    module Argo
      class AdminTest < MiniTest::Test
        include TestHelpers::FakeUI
        include ExtensionTestHelpers::Stubs::ArgoScript

        def setup
          super
          ShopifyCli::ProjectType.load_type(:extension)
          @admin = Features::Argo::Admin.new
        end

        def test_setup_method_returns_the_argo_admin_template
          assert_equal(@admin.git_template, 'https://github.com/Shopify/argo-admin-template.git')
        end

        def test_renderer_package_name_method_returns_the_admin_renderer_package_name_name
          assert_equal(@admin.renderer_package_name, '@shopify/argo-admin')
        end
      end
    end
  end
end
