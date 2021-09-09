describe Script::Layers::Infrastructure::ScriptUploader do
  include TestHelpers::Partners

  describe "UploadScript" do
    let(:ctx) { TestHelpers::FakeContext.new }
    let(:api_key) { "fake_key" }
    let(:script_service) { Script::Layers::Infrastructure::ServiceLocator.script_service(ctx: ctx, api_key: api_key) }
    let(:instance) { Script::Layers::Infrastructure::ScriptUploader.new(script_service) }
    subject { instance.upload(script_content) }

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

  private

  def stub_load_query(name, body)
    ShopifyCLI::API.any_instance.stubs(:load_query).with(name).returns(body)
  end
end
