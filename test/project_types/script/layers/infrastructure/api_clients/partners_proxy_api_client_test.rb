require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::ApiClients::PartnersProxyApiClient do
  include TestHelpers::Partners

  let(:ctx) { TestHelpers::FakeContext.new }
  let(:api_key) { SecureRandom.uuid }
  let(:instance) { Script::Layers::Infrastructure::ApiClients::PartnersProxyApiClient.new(ctx, api_key) }

  describe ".query" do
    let(:query_name) { "<query>" }
    let(:query_body) { "<query body>" }
    let(:variables) { {} }
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

    subject { instance.query(query_name, variables: variables) }

    describe "failed" do
      describe "query errors" do
        before do
          stub_load_query("script_service_proxy", script_service_proxy)
          stub_load_query(query_name, query_body)
          stub_partner_req(
            "script_service_proxy",
            variables: {
              api_key: api_key,
              variables: variables.to_json,
              query: query_body,
            },
            resp: proxy_response
          )
        end

        let(:proxy_response) do
          {
            "errors" => [{
              "extensions" => {
                "code" => code,
              },
            }],
          }
        end

        describe "nil proxy response" do
          let(:proxy_response) { nil }

          it "should raise #{Script::Layers::Infrastructure::Errors::EmptyResponseError}" do
            assert_raises(Script::Layers::Infrastructure::Errors::EmptyResponseError) do
              subject
            end
          end
        end

        describe "forbidden error" do
          let(:code) { "forbidden" }

          it "should raise #{Script::Layers::Infrastructure::Errors::ForbiddenError}" do
            assert_raises(Script::Layers::Infrastructure::Errors::ForbiddenError) do
              subject
            end
          end
        end

        describe "unknown error" do
          let(:code) { "<unknown>" }

          it "should raise #{Script::Layers::Infrastructure::Errors::GraphqlError}" do
            assert_raises(Script::Layers::Infrastructure::Errors::GraphqlError) do
              subject
            end
          end
        end
      end

      describe "wrong response data key" do
        let(:proxy_response) do
          {
            "data" => {
              "<unknown>" => {
                "stuff" => 1,
              },
            },
          }
        end

        before do
          stub_load_query("script_service_proxy", script_service_proxy)
          stub_load_query(query_name, query_body)
          stub_partner_req(
            "script_service_proxy",
            variables: {
              api_key: api_key,
              variables: variables.to_json,
              query: query_body,
            },
            resp: proxy_response
          )
        end

        it "should raise #{Script::Layers::Infrastructure::Errors::InvalidResponseError}" do
          assert_raises(Script::Layers::Infrastructure::Errors::InvalidResponseError) do
            subject
          end
        end
      end

      describe "invalid query" do
        it "should raise #{Errno::ENOENT}" do
          assert_raises(Errno::ENOENT) do
            subject
          end
        end
      end
    end

    describe "success" do
      let(:variables) do
        {
          var1: "a",
          var2: "b",
          var3: "c",
        }
      end
      let(:response) do
        {
          "key1" => 1,
          "key2" => 2,
          "key3" => 3,
        }
      end
      let(:proxy_response) do
        {
          "data" => {
            "scriptServiceProxy" => response.to_json,
          },
        }
      end

      before do
        stub_load_query("script_service_proxy", script_service_proxy)
        stub_load_query(query_name, query_body)
        stub_partner_req(
          "script_service_proxy",
          variables: {
            api_key: api_key,
            variables: variables.to_json,
            query: query_body,
          },
          resp: proxy_response
        )
      end

      it "should return response hash" do
        assert_equal(response, subject)
      end
    end
  end

  private

  def stub_load_query(name, body)
    ShopifyCLI::API.any_instance.stubs(:load_query).with(name).returns(body)
  end
end
