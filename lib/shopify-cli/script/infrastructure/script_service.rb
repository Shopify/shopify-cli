# frozen_string_literal: true

require "shopify_cli"
require "net/http"
require "uri"
require "json"
require "fileutils"

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class ScriptService
        SCRIPT_SERVICE_URL = "https://script-service.shopifycloud.com"
        MOCK_ORG_ID = "100"
        DESCRIPTION_TEMPLATE = "Script '%s' created by CLI tool"
        DEPLOY_FAILED_MSG = "Deploy failed with status %{status} and message %{msg}"
        SCHEMA_FETCH_FAILED = "Failed to fetch schemas with status %{status} and message %{msg}"
        BUILD_FILE = "build.out"
        EXTENSION_POINT_SCHEMA_FILE = "extension_point.schema"
        CONFIG_SCHEMA_FILE = "config.schema"
        private_constant :SCRIPT_SERVICE_URL, :MOCK_ORG_ID, :DESCRIPTION_TEMPLATE, :DEPLOY_FAILED_MSG,
          :SCHEMA_FETCH_FAILED, :BUILD_FILE, :EXTENSION_POINT_SCHEMA_FILE, :CONFIG_SCHEMA_FILE

        def fetch_extension_points
          response = try_request { Net::HTTP.get_response(fetch_uri) }
          validate_response(response, SCHEMA_FETCH_FAILED)
          JSON.parse(response.body)["result"]
        end

        def deploy(
          extension_point_type:,
          schema:,
          script_name:,
          script_content:,
          content_type:,
          shop_id: nil,
          config_value: nil
        )
          form = [
            ["org_id", org_id],
            ["extension_point_name", extension_point_type],
            ["script_content", script_content, filename: BUILD_FILE],
            ["schema", schema, filename: EXTENSION_POINT_SCHEMA_FILE],
            ["title", script_name],
            ["content_type", content_type],
            ["description", get_description(script_name)],
          ]

          form.push(["configuration", config_value]) if config_value
          form.push(["scope", { "shop_id" => shop_id }.to_json]) if scope

          post(form)
        end

        def post(form)
          uri = deploy_uri
          request = Net::HTTP::Post.new(uri)

          Dir.mktmpdir do |temp_dir|
            Dir.chdir(temp_dir) do
              request.set_form(form, "multipart/form-data")
              net_args = { use_ssl: uri.scheme == "https" }
              response = try_request do
                Net::HTTP.start(uri.hostname, uri.port, net_args) do |http|
                  http.request(request)
                end
              end

              validate_response(response, DEPLOY_FAILED_MSG)
            end
          end
        end

        private

        def try_request(&block)
          block.call
        rescue SocketError
          raise Infrastructure::ScriptServiceConnectionError
        end

        def validate_response(response, error_message)
          code = response.code.to_i
          return if code == 200

          if code == 502
            raise Infrastructure::ScriptServiceConnectionError
          else
            raise Domain::ServiceFailureError, format(error_message, msg: response.msg, status: code)
          end
        end

        def build_form_data(
          scope:,
          extension_point_type:,
          script_name:,
          script_content:,
          schema:,
          config_value:,
          content_type:
        )
          form = [
            ["org_id", org_id],
            ["extension_point_name", extension_point_type],
            ["script_content", script_content, filename: BUILD_FILE],
            ["schema", schema, filename: EXTENSION_POINT_SCHEMA_FILE],
            ["title", script_name],
            ["content_type", content_type],
            ["description", get_description(script_name)],
          ]

          form.push(["configuration", config_value]) if config_value
          form.push(["scope", scope]) if scope
          form
        end

        def get_description(name)
          DESCRIPTION_TEMPLATE % name
        end

        def org_id
          MOCK_ORG_ID
        end

        def fetch_uri
          URI.parse("#{uri_base}/extension_points")
        end

        def deploy_uri
          URI.parse("#{uri_base}/deploy")
        end

        def uri_base
          (@_ ||= ENV["SCRIPT_SERVICE_URL"] || SCRIPT_SERVICE_URL).to_s
        end
      end
    end
  end
end
