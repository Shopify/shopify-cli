# frozen_string_literal: true

module Extension
  module ExtensionTestHelpers
    autoload :FakeExtensionProject, 'project_types/extension/extension_test_helpers/fake_extension_project'
    autoload :TestExtension, 'project_types/extension/extension_test_helpers/test_extension'
    autoload :TestExtensionSetup, 'project_types/extension/extension_test_helpers/test_extension_setup'
    autoload :TempProjectSetup, 'project_types/extension/extension_test_helpers/temp_project_setup'
    autoload :Messages, 'project_types/extension/extension_test_helpers/messages'

    module Stubs
      autoload :GetOrganizations, 'project_types/extension/extension_test_helpers/stubs/get_organizations'
      autoload :CreateExtension, 'project_types/extension/extension_test_helpers/stubs/create_extension'
      autoload :UpdateDraft, 'project_types/extension/extension_test_helpers/stubs/update_draft'
      autoload :ArgoScript, 'project_types/extension/extension_test_helpers/stubs/argo_script'
    end
  end
end
