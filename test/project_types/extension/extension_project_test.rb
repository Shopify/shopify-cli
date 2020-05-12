# frozen_string_literal: true
require 'test_helper'
require 'project_types/extension/extension_test_helpers'

module Extension
  class ExtensionProjectTest < MiniTest::Test
    include TestHelpers::FakeUI
    include ExtensionTestHelpers::TempProjectSetup

    def setup
      super
      setup_temp_project
    end

    def test_write_cli_file_create_shopify_cli_yml_file
      new_context = TestHelpers::FakeContext.new(root: Dir.mktmpdir)
      FileUtils.cd(new_context.root)

      ExtensionProject.write_cli_file(context: new_context, type: @type.identifier)

      assert File.exists?('.shopify-cli.yml')
      assert_equal :extension, ShopifyCli::Project.current_project_type
      assert_equal @type, ExtensionProject.current.extension_type
    end

    def test_write_env_file_creates_env_file
      api_key = '1234'
      api_secret = '5678'
      title = 'Test Title'
      registration_id = 55

      new_context = TestHelpers::FakeContext.new(root: Dir.mktmpdir)
      FileUtils.cd(new_context.root)

      ExtensionProject.write_cli_file(context: new_context, type: @type.identifier)
      ExtensionProject.write_env_file(
        context: new_context,
        api_key: api_key,
        api_secret: api_secret,
        title: title,
        registration_id: registration_id
      )

      assert File.exists?('.env')
      project = ExtensionProject.current
      assert_equal api_key, project.app.api_key
      assert_equal api_secret, project.app.secret
      assert_equal title, project.title
      assert_equal registration_id, project.registration_id
    end

    def test_ensures_registered_is_true_only_if_api_key_api_secret_and_registration_id_are_present
      new_ctx = TestHelpers::FakeContext.new(root: Dir.mktmpdir)
      FileUtils.cd(new_ctx.root)
      ExtensionProject.write_cli_file(context: new_ctx, type: @type.identifier)
      project = ExtensionProject.current

      ExtensionProject.write_env_file(context: new_ctx, title: 'title')
      refute project.registered?

      ExtensionProject.write_env_file(context: new_ctx, api_key: '1234', title: 'title')
      refute project.registered?

      ExtensionProject.write_env_file(context: new_ctx, api_key: '1234', api_secret: '456', title: 'title')
      refute project.registered?

      ExtensionProject.write_env_file(context: new_ctx, api_key: '', api_secret: '', title: 'title', registration_id: 5)
      refute project.registered?

      ExtensionProject.write_env_file(
        context: new_ctx,
        api_key: '1234',
        api_secret: '456',
        title: 'title',
        registration_id: 55
      )
      assert project.registered?
    end

    def test_can_access_app_specific_values_as_an_app
      assert_kind_of Models::App, @project.app
      assert_equal @api_key, @project.app.api_key
      assert_equal @api_secret, @project.app.secret
    end

    def test_title_returns_the_title
      assert_equal @title, @project.title
    end

    def test_title_returns_nil_if_title_is_missing
      setup_temp_project(title: nil)
      assert_nil ExtensionProject.current.title
    end

    def test_extension_type_returns_the_set_type_as_a_type_instance
      assert_kind_of Models::Type, @project.extension_type
      assert_equal @type.identifier, @project.extension_type.identifier
    end

    def test_detects_if_registration_id_is_missing_or_invalid
      ExtensionProject.write_env_file(context: @context, title: 'Test')
      refute @project.registration_id?

      ExtensionProject.write_env_file(context: @context, title: 'Test', registration_id: 0)
      refute @project.registration_id?

      ExtensionProject.write_env_file(context: @context, title: 'Test', registration_id: 'wrong')
      refute @project.registration_id?
    end
  end
end
