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
    let(:config_value) { nil }
    let(:shop_id) { nil }
    let(:deploy_uri) { URI.parse((ENV["SCRIPT_SERVICE_URL"] || "https://script-service.shopifycloud.com") + "/deploy") }

    subject do
      script_service.deploy(
        extension_point_type: extension_point_type,
        schema: extension_point_schema,
        script_name: script_name,
        script_content: script_content,
        content_type: "wasm",
        shop_id: shop_id
      )
    end

    describe "when deploy to script service succeeds" do
      let(:form) do
        [
          ["extension_point_name", extension_point_type],
          ["script_content", script_content, filename: "build.out"],
          ["schema", extension_point_schema, filename: "extension_point.schema"],
          ["title", script_name],
          ["content_type", "wasm"],
          ["description", "Script 'foo_bar' created by CLI tool"],
        ]
      end

      describe "when shop_id is nil" do
        let(:shop_id) { nil }

        it "should post the form without scope" do
          script_service.expects(:post).with(form)
          FakeFS.with_fresh do
            subject
          end
        end
      end
      describe "when shop_id exists" do
        let(:shop_id) { 1 }
        let(:scope) { { shop_id: shop_id }.to_json }

        it "should post the form without scope" do
          script_service.expects(:post).with(form + [["scope", scope]])
          FakeFS.with_fresh do
            subject
          end
        end
      end
    end

    describe "when deploy to script service fails" do
      before do
        stub_request(:post, deploy_uri).to_return(status: 500)
      end

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
