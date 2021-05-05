# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  class ExtensionProjectTest < MiniTest::Test
    include TestHelpers::FakeUI

    def setup
      super
      ShopifyCli::ProjectType.load_type(:extension)

      @specification_handler = ExtensionTestHelpers.test_specification_handler
      @api_key = "1234"
      @api_secret = "5678"
      @title = "Test title"
      @registration_id = 56
      @registration_uuid = "eb946ca8-a925-11eb-bcbc-0242ac130013"
      @type = @specification_handler.identifier

      @context = TestHelpers::FakeContext.new(root: Dir.mktmpdir)

      FileUtils.cd(@context.root)
      ExtensionProject.write_cli_file(context: @context, type: @type)
    end

    def test_write_cli_file_create_shopify_cli_yml_file
      ::ShopifyCli::Project.clear

      assert File.exist?(".shopify-cli.yml")
      assert_equal :extension, ShopifyCli::Project.current_project_type
      assert_equal @specification_handler.identifier, ExtensionProject.current.specification_identifier
    end

    def test_write_env_file_creates_env_file
      ExtensionProject.write_env_file(
        context: @context,
        api_key: @api_key,
        api_secret: @api_secret,
        title: @title,
        registration_id: @registration_id,
        registration_uuid: @registration_uuid
      )

      assert File.exist?(".env")
      project = ExtensionProject.current
      assert_equal @api_key, project.app.api_key
      assert_equal @api_secret, project.app.secret
      assert_equal @title, project.title
      assert_equal @registration_id, project.registration_id
      assert_equal @registration_uuid, project.registration_uuid
    end

    def test_env_file_writes_temporary_uuid_if_no_registration_uuid_present
      ExtensionProject.write_env_file(
        context: @context,
        api_key: @api_key,
        api_secret: @api_secret,
        title: @title,
        registration_id: @registration_id
      )

      assert File.exist?(".env")
      project = ExtensionProject.current
      assert project.registration_uuid.start_with?("dev")
    end

    def test_env_file_does_not_write_temporary_registration_uuid_if_uuid_present
      ExtensionProject.write_env_file(
        context: @context,
        api_key: @api_key,
        api_secret: @api_secret,
        title: @title,
        registration_id: @registration_id,
        registration_uuid: @registration_uuid
      )

      assert File.exist?(".env")
      project = ExtensionProject.current
      refute project.registration_uuid.start_with?("dev")
    end

    def test_ensures_registered_is_true_only_if_api_key_api_secret_and_registration_id_are_present
      project = ExtensionTestHelpers.fake_extension_project(api_key: "", api_secret: "", title: "title",
registration_id: nil)
      refute project.registered?

      project = ExtensionTestHelpers.fake_extension_project(api_key: "1234", api_secret: "", title: "title",
registration_id: nil)
      refute project.registered?

      project = ExtensionTestHelpers.fake_extension_project(api_key: "1234", api_secret: "456", title: "title",
registration_id: nil)
      refute project.registered?

      project = ExtensionTestHelpers.fake_extension_project(api_key: "", api_secret: "", title: "title",
registration_id: 5)
      refute project.registered?

      project = ExtensionTestHelpers.fake_extension_project(api_key: "1234", api_secret: "456", title: "title",
registration_id: 55)
      assert project.registered?
    end

    def test_can_access_app_specific_values_as_an_app
      project = ExtensionTestHelpers.fake_extension_project(with_mocks: false, api_key: @api_key,
api_secret: @api_secret)

      assert_kind_of(Models::App, project.app)
      assert_equal @api_key, project.app.api_key
      assert_equal @api_secret, project.app.secret
    end

    def test_title_returns_the_title
      project = ExtensionTestHelpers.fake_extension_project(with_mocks: false, title: @title)

      assert_equal @title, project.title
    end

    def test_title_returns_nil_if_title_is_missing
      project = ExtensionTestHelpers.fake_extension_project(title: nil)
      assert_nil ExtensionProject.current.title
      assert_nil project.title
    end

    def test_extension_type_returns_the_set_type_identifier
      project = ExtensionTestHelpers.fake_extension_project(with_mocks: false)
      assert_equal @type, project.specification_identifier
    end

    def test_detects_if_registration_id_is_missing_or_invalid
      project = ExtensionTestHelpers.fake_extension_project(with_mocks: false, registration_id: nil)
      refute project.registration_id?

      project = ExtensionTestHelpers.fake_extension_project(with_mocks: false, registration_id: 0)
      refute project.registration_id?

      project = ExtensionTestHelpers.fake_extension_project(with_mocks: false, registration_id: "wrong")
      refute project.registration_id?
    end
  end
end
