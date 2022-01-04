# typed: ignore
# frozen_string_literal: true

module Extension
  module ExtensionTestHelpers
    module Stubs
      module UpdateDraft
        include TestHelpers::Partners

        def stub_update_draft(registration_id:, config:, extension_context: nil, api_key: "FAKE_API_KEY")
          stub_partner_req(Tasks::UpdateDraft::GRAPHQL_FILE,
            variables: {
              api_key: api_key,
              registration_id: registration_id,
              config: JSON.generate(config),
              extension_context: extension_context,
            },
            resp: {
              data: yield(registration_id, config, extension_context),
            })
        end

        def stub_update_draft_success(**args)
          stub_update_draft(**args) do |registration_id, _config, extension_context|
            {
              extensionUpdateDraft: {
                extensionVersion: {
                  registrationId: registration_id,
                  context: extension_context,
                  lastUserInteractionAt: Time.now.utc.to_s,
                  location: "https://www.fakeurl.com",
                },
                Tasks::UserErrors::USER_ERRORS_FIELD => [],
              },
            }
          end
        end

        def stub_update_draft_failure(errors:, **args)
          stub_update_draft(**args) do
            {
              extensionUpdateDraft: {
                Tasks::UserErrors::USER_ERRORS_FIELD => errors,
              },
            }
          end
        end
      end
    end
  end
end
