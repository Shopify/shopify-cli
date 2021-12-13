# frozen_string_literal: true

require "shopify_cli"

module Script
  module Layers
    module Application
      class ConnectApp
        class << self
          def call(ctx:, force: false)
            script_project_repo = Layers::Infrastructure::ScriptProjectRepository.new(ctx: ctx)
            script_project = script_project_repo.get

            return false if script_project.env_valid? && !force

            if ShopifyCLI::Shopifolk.check && Forms::RunAgainstShopifyOrg.ask(ctx, nil, nil).response
              ShopifyCLI::Shopifolk.act_as_shopify_organization
            end

            org =
              if partner_proxy_bypass
                stubbed_org
              else
                orgs = ShopifyCLI::PartnersAPI::Organizations.fetch_with_app(ctx)
                Forms::AskOrg.ask(ctx, orgs, nil).org
              end

            app = Forms::AskApp.ask(
              ctx,
              {
                apps: org["apps"],
                acting_as_shopify_organization: ShopifyCLI::Shopifolk.acting_as_shopify_organization?,
              },
              nil
            ).app

            script_service = Layers::Infrastructure::ServiceLocator.script_service(ctx: ctx, api_key: app["apiKey"])
            extension_point_type = script_project.extension_point_type
            scripts = script_service.get_app_scripts(extension_point_type: extension_point_type)

            uuid = Forms::AskScriptUuid.ask(ctx, scripts, nil).uuid

            script_project_repo.create_env(
              api_key: app["apiKey"],
              secret: app["apiSecretKeys"].first["secret"],
              uuid: uuid
            )

            true
          end

          private

          def partner_proxy_bypass
            !ENV["BYPASS_PARTNERS_PROXY"].nil?
          end

          def stubbed_org
            {
              "apps" => [
                {
                  "appType" => "custom",
                  "apiKey" => "stubbed-api-key",
                  "apiSecretKeys" => [{ "secret" => "stubbed-api-secret" }],
                  "title" => "Fake App (Not connected to Partners)",
                },
              ],
            }
          end
        end
      end
    end
  end
end
