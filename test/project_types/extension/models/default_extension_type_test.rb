# frozen_string_literal: true
require 'test_helper'

module Extension
  module Models
    class DefaultExtensionTypeTest < MiniTest::Test
      def setup
        super
        ShopifyCli::ProjectType.load_type(:extension)
        @declaration = TypeDeclaration.new(type: :dynamic, name: 'Dynamic')
      end

      def test_identifier_is_the_declaration_type
        assert_equal @declaration.type, DefaultExtensionType.new(@declaration).identifier
      end

      def test_create_uses_admin_argo_surface_if_feature_argo_surface_is_admin
        declaration = TypeDeclaration.new(type: :dynamic, name: 'Dynamic', feature_argo_surface: :admin)
        directory_name = 'dynamic_extension'

        Features::Argo::Admin.any_instance
          .expects(:create)
          .with(directory_name, 'DYNAMIC', @context)
          .once

        declaration.load_type.create(directory_name, @context)
      end

      def test_create_uses_checkout_argo_surface_if_feature_argo_surface_is_checkout
        declaration = TypeDeclaration.new(type: :dynamic, name: 'Dynamic', feature_argo_surface: :checkout)
        directory_name = 'dynamic_extension'

        Features::Argo::Checkout.any_instance
          .expects(:create)
          .with(directory_name, 'DYNAMIC', @context)
          .once

        declaration.load_type.create(directory_name, @context)
      end

      def test_aborts_create_if_no_features_are_enabled
        @context.expects(:abort).with('Unknown feature set').raises(ShopifyCli::Abort).once
        declaration = TypeDeclaration.new(type: :dynamic, name: 'Dynamic')

        assert_raises(ShopifyCli::Abort) { declaration.load_type.create('dyanmic_extension', @context) }
      end

      def test_admin_and_checkout_have_same_config_implementation_so_just_use_admin
        admin_declaration = TypeDeclaration.new(type: :dynamic, name: 'Dynamic', feature_argo_surface: :admin)
        checkout_declaration = TypeDeclaration.new(type: :dynamic, name: 'Dynamic', feature_argo_surface: :checkout)

        Features::Argo::Admin.any_instance.expects(:config).with(@context).twice

        admin_declaration.load_type.config(@context)
        checkout_declaration.load_type.config(@context)
      end

      def test_aborts_config_if_no_features_are_enabled
        @context.expects(:abort).with('Unknown feature set').raises(ShopifyCli::Abort).once
        declaration = TypeDeclaration.new(type: :dynamic, name: 'Dynamic')

        assert_raises(ShopifyCli::Abort) { declaration.load_type.config(@context) }
      end
    end
  end
end
