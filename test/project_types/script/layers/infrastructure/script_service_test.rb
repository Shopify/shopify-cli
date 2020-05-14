# frozen_string_literal: true

require 'project_types/script/test_helper'

describe Script::Layers::Infrastructure::ScriptService do
  include TestHelpers::Partners

  let(:ctx) { TestHelpers::FakeContext.new }
  let(:script_service) { Script::Layers::Infrastructure::ScriptService.new(ctx: ctx) }
  let(:api_key) { "fake_key" }
  let(:extension_point_type) { "DISCOUNT" }
  let(:script_service_proxy) do
    <<~HERE
      query ProxyRequest($api_key: String, $shop_domain: String, $query: String!, $variables: String) {
        scriptServiceProxy(
          apiKey: $api_key
          shopDomain: $shop_domain
          query: $query
          variables: $variables
        )
      }
    HERE
  end

  describe ".deploy" do
    let(:extension_point_schema) { "schema" }
    let(:script_name) { "foo_bar" }
    let(:script_content) { "(module)" }
    let(:content_type) { "ts" }
    let(:api_key) { "fake_key" }
    let(:schema) { "schema" }
    let(:app_script_update_or_create) do
      <<~HERE
        mutation AppScriptUpdateOrCreate(
          $extensionPointName: ExtensionPointName!,
          $title: String,
          $sourceCode: String,
          $language: String,
          $schema: String
        ) {
          appScriptUpdateOrCreate(
            extensionPointName: $extensionPointName
            title: $title
            sourceCode: $sourceCode
            language: $language
            schema: $schema
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
    end

    before do
      stub_load_query('script_service_proxy', script_service_proxy)
      stub_load_query('app_script_update_or_create', app_script_update_or_create)
      stub_partner_req(
        'script_service_proxy',
        variables: {
          api_key: api_key,
          variables: {
            extensionPointName: extension_point_type,
            title: script_name,
            sourceCode: Base64.encode64(script_content),
            language: "ts",
            schema: extension_point_schema,
            force: false,
          }.to_json,
          query: app_script_update_or_create,
        },
        resp: response
      )
    end

    subject do
      script_service.deploy(
        extension_point_type: extension_point_type,
        schema: extension_point_schema,
        script_name: script_name,
        script_content: script_content,
        compiled_type: "ts",
        api_key: api_key,
      )
    end

    describe "when deploy to script service succeeds" do
      let(:script_service_response) do
        {
          "data" => {
            "appScriptUpdateOrCreate" => {
              "appScript" => {
                "apiKey" => "fake_key",
                "configSchema" => nil,
                "extensionPointName" => extension_point_type,
                "title" => "foo2",
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
        assert_equal(script_service_response, subject)
      end
    end

    describe "when deploy to script service responds with errors" do
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

    describe "when deploy to script service responds with userErrors" do
      describe "when invalid app key" do
        let(:response) do
          {
            data: {
              scriptServiceProxy: JSON.dump(
                "data" => {
                  "appScriptUpdateOrCreate" => {
                    "userErrors" => [{ "message" => "invalid", "field" => "appKey", "tag" => "user_error" }],
                  },
                }
              ),
            },
          }
        end

        it "should raise error" do
          assert_raises(Script::Layers::Infrastructure::Errors::ScriptServiceUserError) { subject }
        end
      end

      describe "when redeploy without a force" do
        let(:response) do
          {
            data: {
              scriptServiceProxy: JSON.dump(
                "data" => {
                  "appScriptUpdateOrCreate" => {
                    "userErrors" => [{ "message" => "error", "tag" => "already_exists_error" }],
                  },
                }
              ),
            },
          }
        end

        it "should raise ScriptRedeployError error" do
          assert_raises(Script::Layers::Infrastructure::Errors::ScriptRedeployError) { subject }
        end
      end
    end
  end

  private

  def stub_load_query(name, body)
    ShopifyCli::API.any_instance.stubs(:load_query).with(name).returns(body)
  end
end
