# frozen_string_literal: true

module Extension
  module ExtensionTestHelpers
    autoload :FakeExtensionProject, "project_types/extension/extension_test_helpers/fake_extension_project"
    autoload :TestExtension, "project_types/extension/extension_test_helpers/test_extension"
    autoload :TestExtensionSetup, "project_types/extension/extension_test_helpers/test_extension_setup"
    autoload :TempProjectSetup, "project_types/extension/extension_test_helpers/temp_project_setup"
    autoload :DummyArgo, "project_types/extension/extension_test_helpers/dummy_argo"
    autoload :DummySpecifications, "project_types/extension/extension_test_helpers/dummy_specifications"

    module Stubs
      autoload :GetOrganizations, "project_types/extension/extension_test_helpers/stubs/get_organizations"
      autoload :GetApp, "project_types/extension/extension_test_helpers/stubs/get_app"
      autoload :CreateExtension, "project_types/extension/extension_test_helpers/stubs/create_extension"
      autoload :UpdateDraft, "project_types/extension/extension_test_helpers/stubs/update_draft"
      autoload :ArgoScript, "project_types/extension/extension_test_helpers/stubs/argo_script"
      autoload :FetchSpecifications, "project_types/extension/extension_test_helpers/stubs/fetch_specifications"
    end

    def self.test_specifications(type_identifier: "TEST_EXTENSION")
      DummySpecifications.build(
        identifier: type_identifier.downcase,
        custom_handler_root: File.expand_path("../", __FILE__),
        custom_handler_namespace: ::Extension::ExtensionTestHelpers,
      )
    end

    def self.test_specification_handler(type_identifier: "TEST_EXTENSION")
      specification_handler = test_specifications[type_identifier]
      if specification_handler.nil?
        raise "Unable to retrieve specification handler due to broken test setup"
      end

      specification_handler
    end

    def self.fake_extension_project(
      with_mocks: false,
      api_key: "TEST_KEY",
      api_secret: "TEST_SECRET",
      directory: "fake/dir",
      title: "Test",
      type_identifier: "TEST_EXTENSION",
      registration_id: 55,
      registration_uuid: "db946ca8-a925-11eb-bcbc-0242ac130002"
    )
      project = FakeExtensionProject.new(
        directory: directory,
        api_key: api_key,
        api_secret: api_secret,
        title: title,
        type: type_identifier,
        registration_id: registration_id,
        registration_uuid: registration_uuid
      )

      if with_mocks
        ShopifyCLI::Project.stubs(:current).returns(project)
        ShopifyCLI::Project.stubs(:has_current?).returns(true)
        ExtensionProject.stubs(:current).returns(project)
        Extension::Loaders::Project.stubs(:load).returns(project)
        specifications = test_specifications(type_identifier: type_identifier)
        Models::Specifications.stubs(:new).returns(specifications)
      end

      project
    end
  end
end
