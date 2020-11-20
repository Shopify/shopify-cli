# frozen_string_literal: true
require 'test_helper'
require 'project_types/extension/extension_test_helpers'

module Extension
  class ExtensionProjectTest < MiniTest::Test
    include TestHelpers::FakeUI
    include ExtensionTestHelpers::TempProjectSetup

    def test_write_cli_file_create_shopify_cli_yml_file
      new_context = TestHelpers::FakeContext.new(root: Dir.mktmpdir)
      FileUtils.cd(new_context.root)

      ExtensionProject.write_cli_file(context: new_context, type: @test_extension_type.identifier)
      ::ShopifyCli::Project.clear

      assert File.exist?('.shopify-cli.yml')
      assert_equal :extension, ShopifyCli::Project.current_project_type
      assert_equal @test_extension_type.identifier, ExtensionProject.current.extension_type_identifier
    end

    def test_write_env_file_creates_env_file
      api_key = '1234'
      api_secret = '5678'
      title = 'Test Title'
      registration_id = 55

      new_context = TestHelpers::FakeContext.new(root: Dir.mktmpdir)
      FileUtils.cd(new_context.root)

      ExtensionProject.write_cli_file(context: new_context, type: @test_extension_type.identifier)
      ExtensionProject.write_env_file(
        context: new_context,
        api_key: api_key,
        api_secret: api_secret,
        title: title,
        registration_id: registration_id
      )

      assert File.exist?('.env')
      project = ExtensionProject.current
      assert_equal api_key, project.app.api_key
      assert_equal api_secret, project.app.secret
      assert_equal title, project.title
      assert_equal registration_id, project.registration_id
    end

    def test_ensures_registered_is_true_only_if_api_key_api_secret_and_registration_id_are_present
      setup_temp_project(api_key: '', api_secret: '', title: 'title', registration_id: nil)
      refute @project.registered?

      setup_temp_project(api_key: '1234', api_secret: '', title: 'title', registration_id: nil)
      refute @project.registered?

      setup_temp_project(api_key: '1234', api_secret: '456', title: 'title', registration_id: nil)
      refute @project.registered?

      setup_temp_project(api_key: '', api_secret: '', title: 'title', registration_id: 5)
      refute @project.registered?

      setup_temp_project(api_key: '1234', api_secret: '456', title: 'title', registration_id: 55)
      assert @project.registered?
    end

    def test_can_access_app_specific_values_as_an_app
      setup_temp_project

      assert_kind_of(Models::App, @project.app)
      assert_equal @api_key, @project.app.api_key
      assert_equal @api_secret, @project.app.secret
    end

    def test_title_returns_the_title
      setup_temp_project

      assert_equal @title, @project.title
    end

    def test_title_returns_nil_if_title_is_missing
      setup_temp_project(title: nil)
      assert_nil(ExtensionProject.current.title)
    end

    def test_extension_type_returns_the_set_type_identifier
      setup_temp_project

      assert_equal @type, @project.extension_type_identifier
    end

    def test_detects_if_registration_id_is_missing_or_invalid
      setup_temp_project(registration_id: nil)
      refute @project.registration_id?

      setup_temp_project(registration_id: 0)
      refute @project.registration_id?

      setup_temp_project(registration_id: 'wrong')
      refute @project.registration_id?
    end
  end
end
