require "test_helper"

describe ShopifyCli::ScriptModule::Infrastructure::ScriptService do
  include TestHelpers::Partners

  let(:ctx) { TestHelpers::FakeContext.new }
  let(:script_service) { ShopifyCli::ScriptModule::Infrastructure::ScriptService.new(ctx: ctx) }
  let(:app_key) { "fake_key" }

  describe ".fetch_extension_points" do
    let(:valid_ep_response) do
      {
        "data" => {
          "extensionPoints" => [
            {
              "name" => "ALLOW_CHECKOUT_COMPLETION",
              "schema" => "schema",
              "types" => "types",
              "scriptExample" => "var i = 0",
            },
            {
              "name" => "DISCOUNT",
              "schema" => "schema",
              "types" => "type",
              "scriptExample" => "var i = 0",
            },
          ],
        },
      }
    end

    let(:extension_point_query) do
      <<~HERE
        {
          extensionPoints {
            name
            schema
            scriptExample
            types
          }
        }
      HERE
    end

    subject { script_service.fetch_extension_points }
    it "should return an array of available extension points" do
      stub_partner_req(
        'script_service_proxy',
        variables: {
          query: extension_point_query,
          app_key: nil,
        },
        resp: {
          data: {
            scriptServiceProxy: JSON.dump(valid_ep_response),
          },
        }
      )

      assert_equal(valid_ep_response, subject)
    end
  end

  describe ".deploy" do
    let(:extension_point_type) { "discount" }
    let(:extension_point_schema) { "schema" }
    let(:script_name) { "foo_bar" }
    let(:script_content) { "(module)" }
    let(:content_type) { "ts" }
    let(:app_key) { "fake_key" }
    let(:schema) { "schema" }

    let(:app_script_create_or_update) do
      <<~HERE
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
    end

    before do
      stub_partner_req(
        'script_service_proxy',
        variables: {
          query: app_script_create_or_update,
          app_key: app_key,
        },
        resp: {
          data: {
            scriptServiceProxy: JSON.dump(response),
          },
        }
      )
    end

    subject do
      script_service.deploy(
        extension_point_type: extension_point_type,
        schema: extension_point_schema,
        script_name: script_name,
        script_content: script_content,
        content_type: "ts",
        app_key: app_key,
      )
    end

    describe "when deploy to script service succeeds" do
      let(:response) do
        {
          "data" => {
            "appScriptUpdateOrCreate" => {
              "appScript" => {
                "appKey" => "fake_key",
                "configSchema" => nil,
                "extensionPointName" => "DISCOUNT",
                "title" => "foo2",
              },
              "userErrors" => [],
            },
          },
        }
      end

      it "should post the form without scope" do
        assert_equal(response, subject)
      end
    end

    describe "when deploy to script service responds with errors" do
      let(:response) do
        {
          "errors" => "errors",
        }
      end

      it "should raise error" do
        assert_raises(ShopifyCli::Abort) { subject }
      end
    end

    describe "when deploy to script service responds with userErrors" do
      let(:response) do
        {
          "data" => {
            "appScriptUpdateOrCreate" => {
              "userErrors" => [{ "message" => "invalid", "field" => "appKey" }],
            },
          },
        }
      end

      it "should raise error" do
        assert_raises(ShopifyCli::Abort) { subject }
      end
    end
  end
end
