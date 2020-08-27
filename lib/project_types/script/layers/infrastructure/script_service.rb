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
          extension_point_type:,
          script_name:,
          script_content:,
          compiled_type:,
          api_key: nil,
          force: false
        )
          query_name = "app_script_update_or_create"
          variables = {
            extensionPointName: extension_point_type.upcase,
            title: script_name,
            sourceCode: Base64.encode64(script_content),
            language: compiled_type,
            force: force,
          }
          resp_hash = script_service_request(query_name: query_name, api_key: api_key, variables: variables)
          user_errors = resp_hash["data"]["appScriptUpdateOrCreate"]["userErrors"]

          return resp_hash if user_errors.empty?

          if user_errors.any? { |e| e['tag'] == 'already_exists_error' }
            raise Errors::ScriptRepushError, api_key
          else
            raise Errors::ScriptServiceUserError.new(query_name, user_errors.to_s)
          end
        end

        def enable(api_key:, shop_domain:, configuration:, extension_point_type:, title:)
          query_name = "shop_script_update_or_create"
          variables = {
            extensionPointName: extension_point_type.upcase,
            configuration: configuration,
            title: title,
          }

          resp_hash = script_service_request(
            query_name: query_name,
            api_key: api_key,
            shop_domain: format_shop_domain(shop_domain),
            variables: variables,
          )
          user_errors = resp_hash["data"]["shopScriptUpdateOrCreate"]["userErrors"]

          return resp_hash if user_errors.empty?

          if user_errors.any? { |e| e['tag'] == 'app_script_not_found' }
            raise Errors::AppScriptUndefinedError, api_key
          elsif user_errors.any? { |e| e['tag'] == 'shop_script_conflict' }
            raise Errors::ShopScriptConflictError
          elsif user_errors.any? { |e| e['tag'] == 'app_script_not_pushed' }
            raise Errors::AppScriptNotPushedError
          else
            raise Errors::ScriptServiceUserError.new(query_name, user_errors.to_s)
          end
        end

        def disable(api_key:, shop_domain:, extension_point_type:)
          query_name = "shop_script_delete"
          variables = {
            extensionPointName: extension_point_type.upcase,
          }

          resp_hash = script_service_request(
            query_name: query_name,
            api_key: api_key,
            shop_domain: format_shop_domain(shop_domain),
            variables: variables,
          )
          user_errors = resp_hash["data"]["shopScriptDelete"]["userErrors"]
          return resp_hash if user_errors.empty?

          if user_errors.any? { |e| e['tag'] == 'shop_script_not_found' }
            raise Errors::ShopScriptUndefinedError, api_key
          else
            raise Errors::ScriptServiceUserError.new(query_name, user_errors.to_s)
          end
        end

        private

        def format_shop_domain(shop_domain)
          shop_domain.delete_suffix("/")
        end

        class ScriptServiceAPI < ShopifyCli::API
          property(:api_key, accepts: String)
          property(:shop_id, accepts: Integer)

          def self.query(ctx, query_name, api_key: nil, shop_domain: nil, variables: {})
            api_client(ctx, api_key, shop_domain).query(query_name, variables: variables)
          end

          def self.api_client(ctx, api_key, shop_domain)
            new(
              ctx: ctx,
              url: 'https://script-service.myshopify.io/graphql',
              token: '',
              api_key: api_key,
              shop_id: shop_domain&.to_i
            )
          end

          def auth_headers(*)
            tokens = { "APP_KEY" => api_key, "SHOP_ID" => shop_id }.compact.to_json
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
          resp = if ENV["BYPASS_PARTNERS_PROXY"]
            ScriptServiceAPI.query(ctx, query_name, variables: variables, **options)
          else
            proxy_through_partners(query_name: query_name, variables: variables, **options)
          end
          raise_if_graphql_failed(resp)
          resp
        end

        def proxy_through_partners(query_name:, variables: nil, **options)
          options[:variables] = variables.to_json if variables
          resp = PartnersProxyAPI.query(ctx, query_name, **options)
          raise_if_graphql_failed(resp)
          JSON.parse(resp['data']['scriptServiceProxy'])
        end

        def raise_if_graphql_failed(response)
          return unless response.key?('errors')
          case error_code(response['errors'])
          when 'forbidden'
            raise Errors::ForbiddenError
          when 'forbidden_on_shop'
            raise Errors::ShopAuthenticationError
          when 'app_not_installed_on_shop'
            raise Errors::AppNotInstalledError
          else
            raise Errors::GraphqlError, response['errors'].map { |e| e['message'] }
          end
        end

        def error_code(errors)
          errors.map do |e|
            code = e.dig('extensions', 'code')
            return code if code
          end
        end
      end
    end
  end
end
