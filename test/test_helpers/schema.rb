# typed: ignore
module TestHelpers
  module Schema
    def setup
      super
      json_data = File.read(File.join(ShopifyCLI::ROOT, "test/fixtures/shopify_schema.json"))
      schema = ShopifyCLI::AdminAPI::Schema[JSON.parse(json_data)]
      ShopifyCLI::AdminAPI::Schema.stubs(:get).returns(schema)
    end
  end
end
