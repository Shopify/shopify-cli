# frozen_string_literal: true

require "base64"
require "json"

module Script
  module Layers
    module Infrastructure
      class ScriptService
        include SmartProperties
        property! :ctx, accepts: ShopifyCli::Context

        def push(
          uuid:,
          extension_point_type:,
          script_content:,
          compiled_type:,
          api_key: nil,
          force: false,
          metadata:,
          script_json:
        )
          query_name = "app_script_update_or_create"
          variables = {
            uuid: uuid,
            extensionPointName: extension_point_type.upcase,
            title: script_json.title,
            description: script_json.description,
            sourceCode: Base64.encode64(script_content),
            language: compiled_type,
            force: force,
            schemaMajorVersion: metadata.schema_major_version.to_s, # API expects string value
            schemaMinorVersion: metadata.schema_minor_version.to_s, # API expects string value
            useMsgpack: metadata.use_msgpack,
            scriptJsonVersion: script_json.version,
            configurationUi: script_json.configuration_ui,
            configurationDefinition: script_json.configuration&.to_json,
          }
          resp_hash = script_service_request(query_name: query_name, api_key: api_key, variables: variables)
          user_errors = resp_hash["data"]["appScriptUpdateOrCreate"]["userErrors"]

          return resp_hash["data"]["appScriptUpdateOrCreate"]["appScript"]["uuid"] if user_errors.empty?

          if user_errors.any? { |e| e["tag"] == "already_exists_error" }
            raise Errors::ScriptRepushError, uuid
          elsif (e = user_errors.any? { |err| err["tag"] == "configuration_syntax_error" })
            raise Errors::ScriptJsonSyntaxError
          elsif (e = user_errors.find { |err| err["tag"] == "configuration_definition_missing_keys_error" })
            raise Errors::ScriptJsonMissingKeysError, e["message"]
          elsif (e = user_errors.find { |err| err["tag"] == "configuration_definition_invalid_value_error" })
            raise Errors::ScriptJsonInvalidValueError, e["message"]
          elsif (e = user_errors.find do |err|
                   err["tag"] == "configuration_definition_schema_field_missing_keys_error"
                 end)
            raise Errors::ScriptJsonFieldsMissingKeysError, e["message"]
          elsif (e = user_errors.find do |err|
                   err["tag"] == "configuration_definition_schema_field_invalid_value_error"
                 end)
            raise Errors::ScriptJsonFieldsInvalidValueError, e["message"]
          elsif user_errors.find { |err| %w(not_use_msgpack_error schema_version_argument_error).include?(err["tag"]) }
            raise Domain::Errors::MetadataValidationError
          else
            raise Errors::GraphqlError, user_errors
          end
        end

        def get_app_scripts(api_key:, extension_point_type:)
          query_name = "get_app_scripts"
          variables = { appKey: api_key, extensionPointName: extension_point_type.upcase }
          script_service_request(query_name: query_name, api_key: api_key, variables: variables)["data"]["appScripts"]
        end

        private

        class ScriptServiceAPI < ShopifyCli::API
          property(:api_key, accepts: String)

          LOCAL_INSTANCE_URL = "https://script-service.myshopify.io"

          def self.query(ctx, query_name, api_key: nil, variables: {})
            api_client(ctx, api_key).query(query_name, variables: variables)
          end

          def self.api_client(ctx, api_key)
            instance_url = spin_instance_url || LOCAL_INSTANCE_URL
            new(
              ctx: ctx,
              url: "#{instance_url}/graphql",
              token: "",
              api_key: api_key
            )
          end

          def self.spin_instance_url
            workspace = ENV["SPIN_WORKSPACE"]
            namespace = ENV["SPIN_NAMESPACE"]
            return if workspace.nil? || namespace.nil?

            "https://script-service.#{workspace}.#{namespace}.us.spin.dev"
          end

          def auth_headers(*)
            tokens = { "APP_KEY" => api_key }.compact.to_json
            { "X-Shopify-Authenticated-Tokens" => tokens }
          end
        end
        private_constant(:ScriptServiceAPI)

        class PartnersProxyAPI < ShopifyCli::PartnersAPI
          def query(query_name, variables: {})
            variables[:query] = load_query(query_name)
            super("script_service_proxy", variables: variables)
          end
        end
        private_constant(:PartnersProxyAPI)

        def script_service_request(query_name:, variables: nil, **options)
          resp = if bypass_partners_proxy
            ScriptServiceAPI.query(ctx, query_name, variables: variables, **options)
          else
            proxy_through_partners(query_name: query_name, variables: variables, **options)
          end
          raise_if_graphql_failed(resp)
          resp
        end

        def bypass_partners_proxy
          !ENV["BYPASS_PARTNERS_PROXY"].nil?
        end

        def proxy_through_partners(query_name:, variables: nil, **options)
          options[:variables] = variables.to_json if variables
          resp = PartnersProxyAPI.query(ctx, query_name, **options)
          raise_if_graphql_failed(resp)
          JSON.parse(resp["data"]["scriptServiceProxy"])
        end

        def raise_if_graphql_failed(response)
          raise Errors::EmptyResponseError if response.nil?

          return unless response.key?("errors")
          case error_code(response["errors"])
          when "forbidden"
            raise Errors::ForbiddenError
          when "forbidden_on_shop"
            raise Errors::ShopAuthenticationError
          when "app_not_installed_on_shop"
            raise Errors::AppNotInstalledError
          else
            raise Errors::GraphqlError, response["errors"]
          end
        end

        def error_code(errors)
          errors.map do |e|
            code = e.dig("extensions", "code")
            return code if code
          end
        end
      end
    end
  end
end
