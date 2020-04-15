# frozen_string_literal: true

module Extension
  module ExtensionTestHelpers
    module Stubs
      module UpdateDraft
        include TestHelpers::Partners

        def stub_update_draft(api_key:, registration_id:, config:, context:)
          stub_partner_req(
            'extension_update_draft',
            variables: {
              api_key: api_key,
              registration_id: registration_id,
              config: config,
              context: context
            },
            resp: {
              data: {
                extensionUpdateDraft: {
                  extensionVersion: {
                    registrationId: registration_id,
                    context: context
                  },
                  userErrors: []
                },
              },
            }
          )
        end

        def stub_update_draft_with_errors(api_key:, registration_id:, config:, context:, errors: [])
          stub_partner_req(
            'extension_update_draft',
            variables: {
              api_key: api_key,
              registration_id: registration_id,
              config: config,
              context: context
            },
            resp: {
              errors: errors
            }
          )
        end
      end
    end
  end
end
