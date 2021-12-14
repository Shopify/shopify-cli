# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  class ExtensionProjectTest < MiniTest::Test
    include TestHelpers::FakeUI

    def setup
      super
      ShopifyCLI::ProjectType.load_type(:extension)

      @specification_handler = ExtensionTestHelpers.test_specification_handler
      @type = @specification_handler.identifier
      @context = TestHelpers::FakeContext.new(root: Dir.mktmpdir)

      FileUtils.cd(@context.root)
      ExtensionProject.write_cli_file(context: @context, type: @type)
    end

    def test_write_cli_file_create_shopify_cli_yml_file
      ::ShopifyCLI::Project.clear

      assert File.exist?(".shopify-cli.yml")
      assert_equal :extension, ShopifyCLI::Project.current_project_type
      assert_equal @specification_handler.identifier, ExtensionProject.current.specification_identifier
    end

    def test_write_env_file_creates_env_file
      assert_nothing_raised { ExtensionProject.write_env_file(**valid_env_file_attributes) }
      assert File.exist?(".env")
    end

    def test_write_env_file_persists_api_key
      ExtensionProject.write_env_file(**valid_env_file_attributes_with(api_key: "abc"))
      assert_equal("abc", ExtensionProject.current.app.api_key)
    end

    def test_write_env_file_persists_api_secret
      ExtensionProject.write_env_file(**valid_env_file_attributes_with(api_secret: "xyz"))
      assert_equal("xyz", ExtensionProject.current.app.secret)
    end

    def test_write_env_file_persists_title
      ExtensionProject.write_env_file(**valid_env_file_attributes_with(title: "Hello World"))
      assert_equal("Hello World", ExtensionProject.current.title)
    end

    def test_write_env_file_persists_registration_id
      ExtensionProject.write_env_file(**valid_env_file_attributes_with(registration_id: 123))
      assert_equal(123, ExtensionProject.current.registration_id)
    end

    def test_write_env_file_persists_registration_uuid
      ExtensionProject.write_env_file(**valid_env_file_attributes_with(registration_uuid: "0000"))
      assert_equal("0000", ExtensionProject.current.registration_uuid)
    end

    def test_write_env_file_persists_resource_url
      ExtensionProject.write_env_file(**valid_env_file_attributes_with(resource_url: "/cart/13:1"))
      assert_equal("/cart/13:1", ExtensionProject.current.resource_url)
    end

    def test_write_env_file_persists_shop
      ExtensionProject.write_env_file(**valid_env_file_attributes_with(shop: "johndoe.myshopify.com"))
      assert_equal("johndoe.myshopify.com", ExtensionProject.current.env.shop)
    end

    def test_env_file_writes_temporary_uuid_if_no_registration_uuid_present
      ExtensionProject.write_env_file(**valid_env_file_attributes_without(:registration_uuid))

      assert File.exist?(".env")
      project = ExtensionProject.current
      assert project.registration_uuid.start_with?("dev")
    end

    def test_env_file_does_not_write_temporary_registration_uuid_if_uuid_present
      ExtensionProject.write_env_file(**valid_env_file_attributes_with(registration_uuid: "123"))

      assert File.exist?(".env")
      project = ExtensionProject.current
      assert_equal "123", project.registration_uuid
    end

    def test_ensures_registered_is_true_only_if_registration_id_is_present
      sets_of_invalid_attributes = [
        { api_key: "", api_secret: "", title: "title", registration_id: nil },
        { api_key: "1234", api_secret: "", title: "title", registration_id: nil },
        { api_key: "1234", api_secret: "456", title: "title", registration_id: nil },
      ]

      sets_of_invalid_attributes.each do |invalid_attributes|
        project = ExtensionTestHelpers.fake_extension_project(**invalid_attributes)
        refute project.registered?
      end

      ExtensionTestHelpers
        .fake_extension_project(api_key: "1234", api_secret: "456", title: "title", registration_id: 55)
        .tap do |project|
          assert project.registered?
        end
    end

    def test_ensures_registered_is_true_if_registration_id_is_present
      project = ExtensionTestHelpers.fake_extension_project(
        api_key: "", api_secret: "", title: "", registration_id: 55
      )
      assert project.registered?
    end

    def test_can_access_app_specific_values_as_an_app
      api_key = "123"
      api_secret = "abc"

      project = ExtensionTestHelpers.fake_extension_project(
        api_key: api_key,
        api_secret: api_secret
      )

      assert_kind_of(Models::App, project.app)
      assert_equal api_key, project.app.api_key
      assert_equal api_secret, project.app.secret
    end

    def test_title_returns_the_title
      title = "Some title"
      project = ExtensionTestHelpers.fake_extension_project(title: title)
      assert_equal title, project.title
    end

    def test_title_returns_nil_if_title_is_missing
      project = ExtensionTestHelpers.fake_extension_project(title: nil, with_mocks: true)
      assert_nil ExtensionProject.current.title
      assert_nil project.title
    end

    def test_extension_type_returns_the_set_type_identifier
      project = ExtensionTestHelpers.fake_extension_project
      assert_equal @type, project.specification_identifier
    end

    def test_detects_if_registration_id_is_missing_or_invalid
      invalid_registration_ids = [nil, 0, "wrong"]

      invalid_registration_ids.each do |invalid_registration_id|
        project = ExtensionTestHelpers.fake_extension_project(
          registration_id: invalid_registration_id
        )
        refute project.registration_id?
      end
    end

    def test_missing_env_file_raises_error_when_accessing_app_attributes
      project = ExtensionProject.new
      refute File.exist?(".env")

      assert_raises CLI::Kit::Abort do
        project.app
      end
    end

    private

    def valid_env_file_attributes_without(*keys)
      attributes = valid_env_file_attributes
      unknown_keys = (keys - attributes.keys)
      raise ArgumentError, "Unknown keys: #{unknown_keys.join(", ")}" if unknown_keys.any?
      attributes.delete_if { |key, _| keys.include?(key) }
    end

    def valid_env_file_attributes_with(**overrides)
      attributes = valid_env_file_attributes
      unknown_keys = (overrides.keys - attributes.keys)
      raise ArgumentError, "Unknown keys: #{unknown_keys.join(", ")}" if unknown_keys.any?
      attributes.merge(overrides)
    end

    def valid_env_file_attributes
      {
        context: @context,
        api_key: "1234",
        api_secret: "5678",
        title: "Test title",
        registration_id: 56,
        registration_uuid: "eb946ca8-a925-11eb-bcbc-0242ac130013",
        resource_url: "/cart/1:1",
        shop: "test.myshopify.com",
      }
    end
  end
end
