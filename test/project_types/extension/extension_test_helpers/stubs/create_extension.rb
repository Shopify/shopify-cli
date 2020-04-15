# frozen_string_literal: true

module Extension
  module ExtensionTestHelpers
    module Stubs
      module CreateExtension
        include TestHelpers::Partners

        def stub_create_extension(api_key:, type:, title:)
          stub_partner_req(
            'extension_create',
            variables: {
              api_key: api_key,
              type: type,
              title: title
            },
            resp: {
              data: {
                extensionCreate: {
                  extensionRegistration: {
                    id: rand(9999),
                    type: type,
                    title: title,
                  },
                  userErrors: []
                },
              },
            }
          )
        end

        def stub_create_extension_with_errors(api_key:, type:, title:, errors: [])
          stub_partner_req(
            'extension_create',
            variables: {
              api_key: api_key,
              type: type,
              title: title
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
