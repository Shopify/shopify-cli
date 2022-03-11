# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::ScriptService do
  let(:ctx) { TestHelpers::FakeContext.new }
  let(:api_key) { "fake_key" }
  let(:api_client) { mock }
  let(:script_service) { Script::Layers::Infrastructure::ScriptService.new(client: api_client, api_key: api_key) }
  let(:extension_point_type) { "DISCOUNT" }
  let(:schema_major_version) { "1" }
  let(:schema_minor_version) { "0" }
  let(:use_msgpack) { true }
  let(:script_config_filename) { "script.config.yml" }
  let(:script_config) do
    Script::Layers::Domain::ScriptConfig.new(
      content: expected_script_config_content,
      filename: script_config_filename,
    )
  end
  let(:title) { "script name" }
  let(:script_config_version) { "1" }
  let(:expected_description) { "some description" }
  let(:expected_configuration_ui) { true }
  let(:expected_script_config_version) { "1" }
  let(:expected_configuration) do
    {
      "type" => "single",
      "schema" => [
        {
          "key" => "configurationKey",
          "name" => "My configuration field",
          "type" => "single_line_text_field",
          "helpText" => "This is some help text",
          "defaultValue" => "This is a default value",
        },
      ],
    }
  end
  let(:expected_script_config_content) do
    {
      "version" => expected_script_config_version,
      "title" => title,
      "description" => expected_description,
      "configuration" => expected_configuration,
    }
  end

  describe ".set_app_script" do
    let(:script_content) { "(module)" }
    let(:api_key) { "fake_key" }
    let(:uuid_from_config) { "uuid_from_config" }
    let(:uuid_from_server) { "uuid_from_server" }
    let(:url) { "https://some-bucket" }
    let(:title) { "title_from_project_config" }
    let(:description) { "description_from_project_config" }
    let(:library_language) { "typescript" }
    let(:library_version) { "1.0.0" }

    let(:library) do
      {
        language: library_language,
        version: library_version,
      }
    end

    before do
      api_client.stubs(:query).returns(response)
    end

    subject do
      script_service.set_app_script(
        uuid: uuid_from_config,
        extension_point_type: extension_point_type,
        title: title,
        description: description,
        metadata: Script::Layers::Domain::Metadata.new(
          schema_major_version,
          schema_minor_version,
          use_msgpack,
        ),
        script_config: script_config,
        module_upload_url: url,
        library: library
      )
    end

    describe "when set_app_script to script service succeeds" do
      let(:response) do
        {
          "data" => {
            "appScriptSet" => {
              "appScript" => {
                "apiKey" => "fake_key",
                "configSchema" => nil,
                "extensionPointName" => extension_point_type,
                "title" => "foo2",
                "uuid" => uuid_from_server,
              },
              "userErrors" => [],
            },
          },
        }
      end

      it "returns the script's uuid" do
        assert_equal(uuid_from_server, subject)
      end
    end

    describe "when set_app_script to script service responds with errors" do
      let(:response) { { "errors" => [{ "message" => "errors" }] } }

      it "should raise error" do
        assert_raises(Script::Layers::Infrastructure::Errors::GraphqlError) { subject }
      end
    end

    describe "when partners responds with errors" do
      let(:response) { { "errors" => [{ "message" => "some error message" }] } }

      it "should raise error" do
        assert_raises(Script::Layers::Infrastructure::Errors::GraphqlError) { subject }
      end
    end

    describe "when set_app_script to script service responds with userErrors" do
      describe "when invalid app key" do
        let(:response) do
          {
            "data" => {
              "appScriptSet" => {
                "userErrors" => [{ "message" => "invalid", "field" => "appKey", "tag" => "user_error" }],
              },
            },
          }
        end

        it "should raise error" do
          assert_raises(Script::Layers::Infrastructure::Errors::GraphqlError) { subject }
        end
      end

      describe "when set_app_script without a force" do
        let(:response) do
          {
            "data" => {
              "appScriptSet" => {
                "userErrors" => [{ "message" => "error", "tag" => "already_exists_error" }],
              },
            },
          }
        end

        it "should raise ScriptRepushError error" do
          assert_raises(Script::Layers::Infrastructure::Errors::ScriptRepushError) { subject }
        end
      end

      describe "when metadata is invalid" do
        let(:response) do
          {
            "data" => {
              "appScriptSet" => {
                "userErrors" => [{ "message" => "error", "tag" => error_tag }],
              },
            },
          }
        end

        describe "when not using msgpack" do
          let(:error_tag) { "not_use_msgpack_error" }
          it "should raise MetadataValidationError error" do
            assert_raises(Script::Layers::Domain::Errors::MetadataValidationError) { subject }
          end
        end

        describe "when invalid schema version" do
          let(:error_tag) { "schema_version_argument_error" }
          it "should raise MetadataValidationError error" do
            assert_raises(Script::Layers::Domain::Errors::MetadataValidationError) { subject }
          end
        end
      end

      describe "when v2 configuration is invalid" do
        let(:response) do
          {
            "data" => {
              "appScriptSet" => {
                "userErrors" => [
                  { "message" => "error1", "tag" => "configuration_definition_error" },
                  { "message" => "error2", "tag" => "configuration_definition_error" },
                ],
              },
            },
          }
        end

        it "should raise ScriptConfigurationDefinitionError" do
          assert_raises_and_validate(
            Script::Layers::Infrastructure::Errors::ScriptConfigurationDefinitionError,
            proc do |e|
              assert_equal(["error1", "error2"], e.messages)
              assert_equal(script_config_filename, e.filename)
            end,
          ) { subject }
        end
      end

      describe "when v1 configuration is invalid" do
        let(:response) do
          {
            "data" => {
              "appScriptSet" => {
                "userErrors" => [{ "message" => error_message, "tag" => error_tag }],
              },
            },
          }
        end

        describe "when missing keys" do
          let(:error_message) { "keys" }
          let(:error_tag) { "configuration_definition_missing_keys_error" }

          it "should raise ScriptConfigMissingKeysError" do
            assert_raises_and_validate(
              Script::Layers::Infrastructure::Errors::ScriptConfigMissingKeysError,
              proc do |e|
                assert_equal(error_message, e.missing_keys)
                assert_equal(script_config_filename, e.filename)
              end,
            ) { subject }
          end
        end

        describe "when fields missing keys" do
          let(:error_message) { "keys" }
          let(:error_tag) { "configuration_definition_schema_field_missing_keys_error" }

          it "should raise ScriptConfigFieldsMissingKeysError" do
            assert_raises_and_validate(
              Script::Layers::Infrastructure::Errors::ScriptConfigFieldsMissingKeysError,
              proc do |e|
                assert_equal(error_message, e.missing_keys)
                assert_equal(script_config_filename, e.filename)
              end,
            ) { subject }
          end
        end

        describe "when invalid value" do
          let(:error_message) { "input modes" }
          let(:error_tag) { "configuration_definition_invalid_value_error" }

          it "should raise ScriptConfigInvalidValueError" do
            assert_raises_and_validate(
              Script::Layers::Infrastructure::Errors::ScriptConfigInvalidValueError,
              proc do |e|
                assert_equal(error_message, e.valid_input_modes)
                assert_equal(script_config_filename, e.filename)
              end,
            ) { subject }
          end
        end

        describe "when fields invalid value" do
          let(:error_message) { "valid types" }
          let(:error_tag) { "configuration_definition_schema_field_invalid_value_error" }

          it "should raise ScriptConfigFieldsInvalidValueError" do
            assert_raises_and_validate(
              Script::Layers::Infrastructure::Errors::ScriptConfigFieldsInvalidValueError,
              proc do |e|
                assert_equal(error_message, e.valid_types)
                assert_equal(script_config_filename, e.filename)
              end,
            ) { subject }
          end
        end

        describe "when invalid syntax" do
          let(:error_message) { "invalid syntax" }
          let(:error_tag) { "configuration_definition_syntax_error" }

          it "should raise ScriptConfigSyntaxError" do
            assert_raises_and_validate(
              Script::Layers::Infrastructure::Errors::ScriptConfigSyntaxError,
              proc { |e| assert_equal(script_config_filename, e.filename) },
            ) { subject }
          end
        end
      end

      describe "when response is empty" do
        let(:response) { nil }

        it "should raise EmptyResponseError error" do
          assert_raises(Script::Layers::Infrastructure::Errors::EmptyResponseError) { subject }
        end
      end
    end
  end

  describe ".get_app_scripts" do
    let(:api_key) { "fake_key" }
    let(:response) do
      {
        "data" => {
          "appScripts" => app_scripts,
        },
      }
    end

    before do
      api_client.stubs(:query).returns(response)
    end

    subject do
      script_service.get_app_scripts(
        extension_point_type: extension_point_type,
      )
    end

    describe "when some app scripts exist" do
      let(:app_scripts) { [{ "id" => 1 }, { "id" => 2 }] }

      it "returns the app scripts" do
        assert_equal app_scripts, subject
      end
    end

    describe "when no app scripts exist" do
      let(:app_scripts) { [] }

      it "returns empty" do
        assert_empty subject
      end
    end
  end

  describe ".generate_module_upload_details" do
    let(:user_errors) { [] }
    let(:url) { nil }
    let(:headers) { {} }
    let(:humanized_max_size) { "" }
    let(:response) do
      {
        "data" => {
          "moduleUploadUrlGenerate" => {
            "userErrors" => user_errors,
            "details" => {
              "headers" => headers,
              "url" => url,
              "humanizedMaxSize" => humanized_max_size,
            },
          },
        },
      }
    end

    before do
      api_client.stubs(:query).returns(response)
    end

    subject { script_service.generate_module_upload_details }

    describe "when a url can be generated" do
      let(:url) { "http://fake.com" }
      let(:headers) { { "header" => "value" } }
      let(:humanized_max_size) { "123 Bytes" }

      it "returns a url" do
        assert_equal url, subject[:url]
      end

      it "returns headers" do
        assert_equal headers, subject[:headers]
      end

      it "returns max size" do
        assert_equal humanized_max_size, subject[:max_size]
      end
    end

    describe "when query returns errors" do
      let(:response) { { "errors" => [{ "message" => "errors" }] } }

      it "should raise #{Script::Layers::Infrastructure::Errors::GraphqlError}" do
        assert_raises(Script::Layers::Infrastructure::Errors::GraphqlError) { subject }
      end
    end

    describe "when query returns userErrors" do
      let(:user_errors) { [{ "message" => "some error", "tag" => "user_error" }] }

      it "should raise #{Script::Layers::Infrastructure::Errors::GraphqlError}" do
        assert_raises(Script::Layers::Infrastructure::Errors::GraphqlError) { subject }
      end
    end

    describe "when response is nil" do
      let(:response) { nil }

      it "should raise #{Script::Layers::Infrastructure::Errors::EmptyResponseError}" do
        assert_raises(Script::Layers::Infrastructure::Errors::EmptyResponseError) { subject }
      end
    end
  end
end
