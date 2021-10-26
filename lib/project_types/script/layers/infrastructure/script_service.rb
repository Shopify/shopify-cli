# frozen_string_literal: true

require "base64"
require "json"

module Script
  module Layers
    module Infrastructure
      class ScriptService
        def initialize(client:, api_key:)
          @client = client
          @api_key = api_key
        end

        def set_app_script(
          uuid:,
          extension_point_type:,
          force: false,
          metadata:,
          script_json:,
          module_upload_url:,
          library:
        )
          query_name = "app_script_set"
          variables = {
            uuid: uuid,
            extensionPointName: extension_point_type.upcase,
            title: script_json.title,
            description: script_json.description,
            force: force,
            schemaMajorVersion: metadata.schema_major_version.to_s, # API expects string value
            schemaMinorVersion: metadata.schema_minor_version.to_s, # API expects string value
            scriptJsonVersion: script_json.version,
            configurationUi: script_json.configuration_ui,
            configurationDefinition: script_json.configuration&.to_json,
            moduleUploadUrl: module_upload_url,
            library: {
              language: library[:language],
              version: library[:version],
            },
          }
          resp_hash = make_request(query_name: query_name, variables: variables)
          user_errors = resp_hash["data"]["appScriptSet"]["userErrors"]

          return resp_hash["data"]["appScriptSet"]["appScript"]["uuid"] if user_errors.empty?

          if user_errors.any? { |e| e["tag"] == "already_exists_error" }
            raise Errors::ScriptRepushError, uuid
          elsif (e = user_errors.any? { |err| err["tag"] == "configuration_definition_syntax_error" })
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

        def get_app_scripts(extension_point_type:)
          query_name = "get_app_scripts"
          variables = { appKey: @api_key, extensionPointName: extension_point_type.upcase }
          response = make_request(query_name: query_name, variables: variables)
          response["data"]["appScripts"]
        end

        def generate_module_upload_url
          query_name = "module_upload_url_generate"
          variables = {}
          response = make_request(query_name: query_name, variables: variables)
          user_errors = response["data"]["moduleUploadUrlGenerate"]["userErrors"]

          raise Errors::GraphqlError, user_errors if user_errors.any?
          response["data"]["moduleUploadUrlGenerate"]["url"]
        end

        private

        def make_request(query_name:, variables: {})
          response = @client.query(query_name, variables: variables)
          raise Errors::EmptyResponseError if response.nil?
          raise Errors::GraphqlError, response["errors"] if response.key?("errors")

          response
        end
      end
    end
  end
end
