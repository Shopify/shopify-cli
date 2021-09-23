require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::ApiClients::ScriptServiceApiClient do
  include TestHelpers::Partners

  let(:ctx) { TestHelpers::FakeContext.new }
  let(:api_key) { "api-key" }

  it "#initialize local environment" do
    ShopifyCLI::API.expects(:new).with(
      ctx: ctx,
      url: "https://script-service.myshopify.io/graphql",
      token: { "APP_KEY" => api_key }.compact.to_json,
      auth_header: "X-Shopify-Authenticated-Tokens"
    )

    Script::Layers::Infrastructure::ApiClients::ScriptServiceApiClient.new(ctx, api_key)
  end

  it "#initialize spin environment" do
    ShopifyCLI::Environment.expects(:spin_url).returns("abcd.user.us.spin.dev")
    ShopifyCLI::Environment.expects(:use_spin?).returns(true)

    ShopifyCLI::API.expects(:new).with(
      ctx: ctx,
      url: "https://script-service.abcd.user.us.spin.dev/graphql",
      token: { "APP_KEY" => api_key }.compact.to_json,
      auth_header: "X-Shopify-Authenticated-Tokens"
    )

    Script::Layers::Infrastructure::ApiClients::ScriptServiceApiClient.new(ctx, api_key)
  end
end
