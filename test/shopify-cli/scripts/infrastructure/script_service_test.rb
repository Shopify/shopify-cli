require "test_helper"

describe ShopifyCli::ScriptModule::Infrastructure::ScriptService do
  let(:script_service) { ShopifyCli::ScriptModule::Infrastructure::ScriptService.new }
  let(:fetch_uri) { URI.parse((ENV["SCRIPT_SERVICE_URL"] || "https://script-service.shopifycloud.com") + "/extension_points") }

  describe ".fetch_extension_points" do
    subject { script_service.fetch_extension_points }
    it "should return an array of available extension points" do
      stub_request(:get, fetch_uri)
        .to_return(status: 200, body: "{\"result\": [1, 2, 3]}")

      assert_equal [1, 2, 3], subject
    end

    it "should return an array of available extension points" do
      stub_request(:get, fetch_uri)
        .to_return(status: 502, body: "Bad Gateway")

      assert_raises ShopifyCli::ScriptModule::Infrastructure::ScriptServiceConnectionError do
        subject.fetch_extension_points
      end
    end
  end

  describe ".deploy" do
    let(:extension_point_type) { "discount" }
    let(:extension_point_schema) { "schema" }
    let(:script_name) { "foo_bar" }
    let(:script_content) { "(module)" }
    let(:config_schema) { "config" }
    let(:config_value) { nil }
    let(:shop_id) { nil }
    let(:deploy_uri) { URI.parse((ENV["SCRIPT_SERVICE_URL"] || "https://script-service.shopifycloud.com") + "/deploy") }

    subject do
      script_service.deploy(
        extension_point_type: extension_point_type,
        extension_point_schema: extension_point_schema,
        script_name: script_name,
        script_content: script_content,
        content_type: "wasm",
        config_schema: config_schema,
      )
    end

    before do
      form = [
        ["org_id", "100"],
        ["extension_point_name", extension_point_type],
        ["source_code", script_content, filename: "build.wasm"],
        ["input_schema", extension_point_schema, filename: "extension_point.schema"],
        ["title", script_name],
        ["description", "Script 'foo_bar' created by CLI tool"],
        ["config_schema", config_schema, filename: "config.schema"],
      ]

      form.push(["configuration", config_value]) if config_value
      form.push(["shop_id", "1"]) if shop_id

      stub_request(:post, deploy_uri).with do |req|
        req.body = form
      end.to_return(http_result)
    end

    describe "when deploy to script service succeeds" do
      let(:http_result) { { status: 200 } }

      it "should deploy to script service" do
        FakeFS.with_fresh do
          subject
        end
      end
    end

    describe "when deploy to script service fails" do
      let(:http_result) { { status: 500 } }

      it "should fail to deploy to script service" do
        assert_raises ShopifyCli::ScriptModule::Domain::ServiceFailureError do
          FakeFS.with_fresh do
            subject
          end
        end
      end
    end
  end
end
