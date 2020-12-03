# frozen_string_literal: true

module Extension
  module ExtensionTestHelpers
    module Stubs
      module GetTypeDeclarations
        include TestHelpers::Partners

        def stub_get_type_declarations(declarations)
          stub_partner_req(
            'get_type_declarations',
            resp: {
              data: {
                extensionTypeDeclarations: create_type_declarations_json(declarations),
              },
            },
          )
        end

        def create_type_declarations_json(declarations)
          declarations.map do |declaration|
            {
              type: declaration.type.to_s,
              name: declaration.name,
              features: {
                argo: {
                  surface: declaration.feature_argo_surface.to_s
                }
              }
            }
          end
        end
      end
    end
  end
end
