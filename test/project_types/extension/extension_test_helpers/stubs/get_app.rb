# typed: ignore
# frozen_string_literal: true

module Extension
  module ExtensionTestHelpers
    module Stubs
      module GetApp
        include TestHelpers::Partners

        def stub_get_app(api_key:, app:)
          stub_partner_req(
            "get_app_by_api_key",
            variables: {
              api_key: api_key,
            },
            resp: {
              data: {
                app: create_app_json(app: app),
              },
            },
          )
        end

        def create_app_json(app:)
          return nil if app.nil?

          {
            id: rand(9999),
            title: app.title,
            'apiKey': app.api_key,
            'apiSecretKeys': [{ 'secret': app.secret }],
            'businessName': app.business_name,
          }
        end
      end
    end
  end
end
