# frozen_string_literal: true

require "base64"
require "shopify_cli"
require "net/http"
require "uri"
require "json"
require "fileutils"

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class ScriptService
        include SmartProperties

        DEPLOY_FAILED_MSG = "Deploy failed with status %{status} and message %{msg}"
        SCHEMA_FETCH_FAILED = "Failed to fetch schemas with status %{status} and message %{msg}"
        private_constant :DEPLOY_FAILED_MSG, :SCHEMA_FETCH_FAILED

        property! :ctx, accepts: ShopifyCli::Context

        def fetch_extension_points
          query = <<~HERE
            {
              extensionPoints {
                name
                schema
                scriptExample
                types
              }
            }
          HERE

          proxy_request(query: query, api_key: nil)
        end

        def deploy(
          extension_point_type:,
          schema:,
          script_name:,
          script_content:,
          content_type:,
          api_key: nil
        )
          query = <<~HERE
            mutation {
              appScriptUpdateOrCreate(
                extensionPointName: #{extension_point_type.upcase}
                title: #{script_name.inspect}
                sourceCode: #{Base64.encode64(script_content).inspect}
                language: #{content_type.inspect}
                schema: #{schema.inspect}
            ) {
                userErrors {
                  field
                  message
                }
                appScript {
                  appKey
                  configSchema
                  extensionPointName
                  title
                }
              }
            }
          HERE
          resp_hash = proxy_request(query: query, api_key: api_key)

          unless resp_hash["data"]["appScriptUpdateOrCreate"]["userErrors"].empty?
            raise(ShopifyCli::Abort, resp_hash["data"]["appScriptUpdateOrCreate"]["userErrors"].to_s)
          end
          resp_hash
        end

        private

        def proxy_request(variables)
          resp = Helpers::PartnersAPI.query(ctx, "script_service_proxy", **variables)
          resp_hash = JSON.parse(resp["data"]["scriptServiceProxy"])

          if resp_hash.key?("errors")
            raise(ShopifyCli::Abort, resp_hash["errors"].to_s)
          end
          resp_hash
        end
      end
    end
  end
end
