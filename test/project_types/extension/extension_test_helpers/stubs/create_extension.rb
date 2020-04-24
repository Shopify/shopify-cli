# frozen_string_literal: true

module Extension
  module ExtensionTestHelpers
    module Stubs
      module CreateExtension
        include TestHelpers::Partners

        def stub_create_extension(api_key:, type:, title:, config:, extension_context: nil)
          stub_partner_req(
            'extension_create',
            variables: {
              api_key: api_key,
              type: type,
              title: title,
              config: JSON.generate(config),
              extension_context: extension_context
            },
            resp: {
              data: yield(title, type, config, extension_context)
            }
          )
        end

        def stub_create_extension_success(**args)
          stub_create_extension(args) do |title, type|
            {
              extensionCreate: {
                extensionRegistration: {
                  id: rand(9999),
                  type: type,
                  title: title
                },
                userErrors: []
              },
            }
          end
        end

        def stub_create_extension_failure(userErrors:, **args)
          stub_create_extension(args) do
            {
              extensionCreate: {
                userErrors: userErrors
              },
            }
          end
        end
      end
    end
  end
end
