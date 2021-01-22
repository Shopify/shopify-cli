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

  describe ".push" do
    let(:script_name) { "foo_bar" }
    let(:script_content) { "(module)" }
    let(:api_key) { "fake_key" }
    let(:app_script_update_or_create) do
      <<~HERE
        mutation AppScriptUpdateOrCreate(
          $extensionPointName: ExtensionPointName!,
          $title: String,
          $sourceCode: String,
          $language: String,
        ) {
          appScriptUpdateOrCreate(
            extensionPointName: $extensionPointName
            title: $title
            sourceCode: $sourceCode
            language: $language
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
            language: "AssemblyScript",
            force: false,
          }.to_json,
          query: app_script_update_or_create,
        },
        resp: response
      )
    end

    subject do
      script_service.push(
        extension_point_type: extension_point_type,
        script_name: script_name,
        script_content: script_content,
        compiled_type: "AssemblyScript",
        api_key: api_key,
      )
    end

    describe "when push to script service succeeds" do
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

      describe "when repush without a force" do
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

        it "should raise ScriptRepushError error" do
          assert_raises(Script::Layers::Infrastructure::Errors::ScriptRepushError) { subject }
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

  describe '.enable' do
    let(:api_key) { 'api_key' }
    let(:shop_domain) { 'my.shop.com' }
    let(:formatted_shop_domain) { 'my.shop.com' }
    let(:configuration) { '{}' }
    let(:extension_point_type) { 'discount' }
    let(:title) { 'title' }
    let(:shop_script_update_or_create) do
      <<~HERE
        mutation ShopScriptUpdateOrCreate(
          $extensionPointName: ExtensionPointName!,
          $configuration: String,
          $title: String
        ) {
          shopScriptUpdateOrCreate(
            extensionPointName: $extensionPointName,
            configuration: $configuration,
            title: $title
        ) {
            userErrors {
              field
              message
              tag
            }
            shopScript {
              extensionPointName
              shopId
              title
              configuration
            }
          }
        }
      HERE
    end
    let(:response) do
      {
        data: {
          scriptServiceProxy: JSON.dump(script_service_response),
        },
      }
    end

    before do
      stub_load_query('script_service_proxy', script_service_proxy)
      stub_load_query('shop_script_update_or_create', shop_script_update_or_create)
      stub_partner_req(
        'script_service_proxy',
        variables: {
          api_key: api_key,
          shop_domain: formatted_shop_domain,
          variables: {
            extensionPointName: extension_point_type.upcase,
            configuration: configuration,
            title: title,
          }.to_json,
          query: shop_script_update_or_create,
        },
        resp: response
      )
    end

    subject do
      script_service.enable(
        api_key: api_key,
        shop_domain: shop_domain,
        configuration: configuration,
        extension_point_type: extension_point_type,
        title: title
      )
    end

    describe 'when shop domain ends with /' do
      let(:shop_domain) { 'my.shop.com/' }
      let(:script_service_response) do
        {
          "data" => {
            "shopScriptUpdateOrCreate" => {
              "shopScript" => {
                "shopId" => "1",
                "configuration" => nil,
                "extensionPointName" => extension_point_type,
                "title" => "foo2",
              },
              "userErrors" => [],
            },
          },
        }
      end

      it 'should have no errors when shop domain is formatted' do
        assert_equal(script_service_response, subject)
      end
    end

    describe 'when successful' do
      let(:script_service_response) do
        {
          "data" => {
            "shopScriptUpdateOrCreate" => {
              "shopScript" => {
                "shopId" => "1",
                "configuration" => nil,
                "extensionPointName" => extension_point_type,
                "title" => "foo2",
              },
              "userErrors" => [],
            },
          },
        }
      end

      it 'should have no errors' do
        assert_equal(script_service_response, subject)
      end
    end

    describe 'when failure' do
      let(:tag) { nil }
      let(:script_service_response) do
        {
          "data" => {
            "shopScriptUpdateOrCreate" => {
              "shopScript" => {},
              "userErrors" => [{ "message" => 'error', "tag" => tag }],
            },
          },
        }
      end

      describe 'when app script not found' do
        let(:tag) { "app_script_not_found" }

        it 'should raise AppScriptUndefinedError' do
          assert_raises(Script::Layers::Infrastructure::Errors::AppScriptUndefinedError) { subject }
        end
      end

      describe 'when app script not pushed' do
        let(:tag) { "app_script_not_pushed" }

        it 'should raise AppScriptNotPushedError' do
          assert_raises(Script::Layers::Infrastructure::Errors::AppScriptNotPushedError) { subject }
        end
      end

      describe 'when shop script conflict' do
        let(:tag) { "shop_script_conflict" }

        it 'should raise ShopScriptConflictError' do
          assert_raises(Script::Layers::Infrastructure::Errors::ShopScriptConflictError) { subject }
        end
      end

      describe 'when general error' do
        let(:script_service_response) do
          {
            "data" => {
              "shopScriptUpdateOrCreate" => {
                "shopScript" => {},
                "userErrors" => [{ "message" => 'error' }],
              },
            },
          }
        end

        it 'should raise ScriptServiceUserError' do
          assert_raises(Script::Layers::Infrastructure::Errors::ScriptServiceUserError) { subject }
        end
      end
    end
  end

  describe ".disable" do
    let(:extension_point_type) { "DISCOUNT" }
    let(:shop_domain) { 'shop.myshopify.com' }
    let(:formatted_shop_domain) { 'shop.myshopify.com' }
    let(:api_key) { "fake_key" }
    let(:shop_script_delete) do
      <<~HERE
        mutation ShopScriptDelete($extensionPointName: ExtensionPointName!) {
          shopScriptDelete(extensionPointName: $extensionPointName) {
            userErrors {
              field
              message
              tag
            }
            shopScript {
              extensionPointName
              shopId
              title
            }
          }
        }
      HERE
    end

    let(:response) do
      {
        data: {
          scriptServiceProxy: JSON.dump(script_service_response),
        },
      }
    end

    before do
      stub_load_query('script_service_proxy', script_service_proxy)
      stub_load_query('shop_script_delete', shop_script_delete)
      stub_partner_req(
        'script_service_proxy',
        variables: {
          api_key: api_key,
          shop_domain: formatted_shop_domain,
          variables: {
            extensionPointName: extension_point_type,
          }.to_json,
          query: shop_script_delete,
        },
        resp: response
      )
    end

    subject do
      script_service.disable(
        extension_point_type: extension_point_type,
        api_key: api_key,
        shop_domain: shop_domain,
      )
    end

    describe 'when shop domain ends with /' do
      let(:shop_domain) { 'shop.myshopify.com' }
      let(:script_service_response) do
        {
          "data" => {
            "shopScriptDelete" => {
              "shopScript" => {
                "shopId" => "1",
                "extensionPointName" => extension_point_type,
                "title" => "foo2",
              },
              "userErrors" => [],
            },
          },
        }
      end

      it 'should have no errors when shop domain is formatted' do
        assert_equal(script_service_response, subject)
      end
    end

    describe 'when successful' do
      let(:script_service_response) do
        {
          "data" => {
            "shopScriptDelete" => {
              "shopScript" => {
                "shopId" => "1",
                "extensionPointName" => extension_point_type,
                "title" => "foo2",
              },
              "userErrors" => [],
            },
          },
        }
      end

      it 'should have no errors' do
        assert_equal(script_service_response, subject)
      end
    end

    describe 'when failure' do
      describe 'when shop_script_not_found error' do
        let(:script_service_response) do
          {
            "data" => {
              "shopScriptDelete" => {
                "shopScript" => {},
                "userErrors" => [{ "message" => 'error', "tag" => "shop_script_not_found" }],
              },
            },
          }
        end

        it 'should raise ShopScriptUndefinedError' do
          assert_raises(Script::Layers::Infrastructure::Errors::ShopScriptUndefinedError) { subject }
        end
      end

      describe 'when other error' do
        let(:script_service_response) do
          {
            "data" => {
              "shopScriptDelete" => {
                "shopScript" => {},
                "userErrors" => [{ "message" => 'error', "tag" => "other_error" }],
              },
            },
          }
        end

        it 'should raise ShopScriptUndefinedError' do
          assert_raises(Script::Layers::Infrastructure::Errors::ScriptServiceUserError) { subject }
        end
      end
    end
  end

  private

  def stub_load_query(name, body)
    ShopifyCli::API.any_instance.stubs(:load_query).with(name).returns(body)
  end
end
