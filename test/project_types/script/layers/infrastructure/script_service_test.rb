# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::ScriptService do
  include TestHelpers::Partners

  let(:ctx) { TestHelpers::FakeContext.new }
  let(:api_key) { "fake_key" }
  let(:script_service) { Script::Layers::Infrastructure::ScriptService.new(ctx: ctx, api_key: api_key) }
  let(:extension_point_type) { "DISCOUNT" }
  let(:schema_major_version) { "1" }
  let(:schema_minor_version) { "0" }
  let(:use_msgpack) { true }
  let(:script_json) do
    Script::Layers::Domain::ScriptJson.new(content: expected_script_json_content)
  end
  let(:script_name) { "script name" }
  let(:script_json_version) { "1" }
  let(:expected_description) { "some description" }
  let(:expected_configuration_ui) { true }
  let(:expected_script_json_version) { "1" }
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
  let(:expected_script_json_content) do
    {
      "version" => expected_script_json_version,
      "title" => script_name,
      "description" => expected_description,
      "configurationUi" => expected_configuration_ui,
      "configuration" => expected_configuration,
    }
  end
  let(:script_service_proxy) do
    <<~HERE
      query ProxyRequest($api_key: String, $query: String!, $variables: String) {
        scriptServiceProxy(
          apiKey: $api_key
          query: $query
          variables: $variables
        )
      }
    HERE
  end

  describe ".push" do
    let(:script_content) { "(module)" }
    let(:api_key) { "fake_key" }
    let(:uuid_from_config) { "uuid_from_config" }
    let(:uuid_from_server) { "uuid_from_server" }
    let(:app_script_set) do
      <<~HERE
        mutation AppScriptSet(
          $uuid: String
          $extensionPointName: ExtensionPointName!,
          $title: String!,
          $description: String,
          $force: Boolean,
          $schemaMajorVersion: String,
          $schemaMinorVersion: String,
          $scriptJsonVersion: String!,
          $configurationUi: Boolean!,
          $configurationDefinition: String!,
          $moduleUploadUrl: String!,
        ) {
          appScriptSet(
            uuid: $uuid
            extensionPointName: $extensionPointName
            title: $title
            description: $description
            force: $force
            schemaMajorVersion: $schemaMajorVersion
            schemaMinorVersion: $schemaMinorVersion,
            scriptJsonVersion: $scriptJsonVersion,
            configurationUi: $configurationUi,
            configurationDefinition: $configurationDefinition,
            moduleUploadUrl: $moduleUploadUrl,
        ) {
            userErrors {
              field
              message
              tag
            }
            appScript {
              uuid
              appKey
              configSchema
              extensionPointName
              title
            }
          }
        }
      HERE
    end
    let(:url) { "https://some-bucket" }

    before do
      stub_load_query("script_service_proxy", script_service_proxy)
      stub_load_query("app_script_set", app_script_set)
      stub_partner_req(
        "script_service_proxy",
        variables: {
          api_key: api_key,
          variables: {
            uuid: uuid_from_config,
            extensionPointName: extension_point_type,
            title: script_name,
            description: expected_description,
            force: false,
            schemaMajorVersion: schema_major_version,
            schemaMinorVersion: schema_minor_version,
            scriptJsonVersion: expected_script_json_version,
            configurationUi: expected_configuration_ui,
            configurationDefinition: expected_configuration&.to_json,
            moduleUploadUrl: url,
          }.to_json,
          query: app_script_set,
        },
        resp: response
      )
      Script::Layers::Infrastructure::ScriptService::UploadScript.any_instance.stubs(:call).returns(url)
    end

    subject do
      script_service.push(
        uuid: uuid_from_config,
        extension_point_type: extension_point_type,
        metadata: Script::Layers::Domain::Metadata.new(
          schema_major_version,
          schema_minor_version,
          use_msgpack,
        ),
        script_content: script_content,
        script_json: script_json,
        api_key: api_key,
      )
    end

    describe "when push to script service succeeds" do
      let(:script_service_response) do
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

      let(:response) do
        {
          data: {
            scriptServiceProxy: JSON.dump(script_service_response),
          },
        }
      end

      it "should post the form without scope" do
        assert_equal(uuid_from_server, subject)
      end
    end

    describe "when push to script service responds with errors" do
      let(:response) do
        {
          data: {
            scriptServiceProxy: JSON.dump("errors" => [{ message: "errors" }]),
          },
        }
      end

      it "should raise error" do
        assert_raises(Script::Layers::Infrastructure::Errors::GraphqlError) { subject }
      end
    end

    describe "when partners responds with errors" do
      let(:response) do
        {
          errors: [{ message: "some error message" }],
        }
      end

      it "should raise error" do
        assert_raises(Script::Layers::Infrastructure::Errors::GraphqlError) { subject }
      end
    end

    describe "when push to script service responds with userErrors" do
      describe "when invalid app key" do
        let(:response) do
          {
            data: {
              scriptServiceProxy: JSON.dump(
                "data" => {
                  "appScriptSet" => {
                    "userErrors" => [{ "message" => "invalid", "field" => "appKey", "tag" => "user_error" }],
                  },
                }
              ),
            },
          }
        end

        it "should raise error" do
          assert_raises(Script::Layers::Infrastructure::Errors::GraphqlError) { subject }
        end
      end

      describe "when repush without a force" do
        let(:response) do
          {
            data: {
              scriptServiceProxy: JSON.dump(
                "data" => {
                  "appScriptSet" => {
                    "userErrors" => [{ "message" => "error", "tag" => "already_exists_error" }],
                  },
                }
              ),
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
            data: {
              scriptServiceProxy: JSON.dump(
                "data" => {
                  "appScriptSet" => {
                    "userErrors" => [{ "message" => "error", "tag" => error_tag }],
                  },
                }
              ),
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

      describe "when response is empty" do
        let(:response) { nil }

        it "should raise EmptyResponseError error" do
          assert_raises(Script::Layers::Infrastructure::Errors::EmptyResponseError) { subject }
        end
      end
    end
  end

  describe "UploadScript" do
    let(:instance) { Script::Layers::Infrastructure::ScriptService::UploadScript.new(script_service) }
    subject { instance.call(api_key, script_content) }

    let(:api_key) { "fake_key" }
    let(:script_content) { "(module)" }
    let(:module_upload_url_generate) do
      <<~HERE
        mutation moduleUploadUrlGenerate {
          moduleUploadUrlGenerate {
            url
            userErrors {
              field
              message
            }
          }
        }
        HERE
    end
    let(:url) { "https://some-bucket" }
    let(:response) do
      {
        data: {
          scriptServiceProxy: JSON.dump(script_service_response),
        },
      }
    end

    before do
      stub_load_query("script_service_proxy", script_service_proxy)
      stub_load_query("module_upload_url_generate", module_upload_url_generate)
      stub_partner_req(
        "script_service_proxy",
        variables: {
          api_key: api_key,
          variables: {}.to_json,
          query: module_upload_url_generate,
        },
        resp: response
      )
    end

    describe "when fail to apply module upload url" do
      let(:script_service_response) do
        {
          "data" => {
            "moduleUploadUrlGenerate" => {
              "url" => nil,
              "userErrors" => [{ "message" => "invalid", "field" => "appKey", "tag" => "user_error" }],
            },
          },
        }
      end

      it "should raise GraphqlError" do
        assert_raises(Script::Layers::Infrastructure::Errors::GraphqlError) { subject }
      end
    end

    describe "when succeed to apply module upload url" do
      let(:script_service_response) do
        {
          "data" => {
            "moduleUploadUrlGenerate" => {
              "url" => url,
              "userErrors" => [],
            },
          },
        }
      end

      describe "when fail to upload module" do
        before do
          stub_request(:put, url).with(
            headers: { "Content-Type" => "application/wasm" },
            body: script_content
          ).to_return(status: 500)
        end

        it "should raise an ScriptUploadError" do
          assert_raises(Script::Layers::Infrastructure::Errors::ScriptUploadError) { subject }
        end
      end

      describe "when succeed to upload module" do
        before do
          stub_request(:put, url).with(
            headers: { "Content-Type" => "application/wasm" },
            body: script_content
          ).to_return(status: 200)
        end

        it "should return the url" do
          assert_equal(url, subject)
        end
      end
    end
  end

  describe ".get_app_scripts" do
    let(:api_key) { "fake_key" }
    let(:get_app_scripts) do
      <<~HERE
        query GetAppScripts($appKey: String!, $extensionPointName: ExtensionPointName!) {
          appScripts(appKeys: [$appKey], extensionPointName: $extensionPointName) {
            uuid
            title
          }
        }
      HERE
    end
    let(:partners_response) do
      {
        "data" => {
          "scriptServiceProxy" => JSON.dump(script_service_response),
        },
      }
    end
    let(:script_service_response) do
      {
        "data" => {
          "appScripts" => app_scripts,
        },
      }
    end

    before do
      stub_load_query("script_service_proxy", script_service_proxy)
      stub_load_query("get_app_scripts", get_app_scripts)
      stub_partner_req(
        "script_service_proxy",
        variables: {
          api_key: api_key,
          variables: {
            appKey: api_key,
            extensionPointName: extension_point_type,
          }.to_json,
          query: get_app_scripts,
        },
        resp: partners_response
      )
    end

    subject do
      script_service.get_app_scripts(
        api_key: api_key,
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

  private

  def stub_load_query(name, body)
    ShopifyCli::API.any_instance.stubs(:load_query).with(name).returns(body)
  end
end
