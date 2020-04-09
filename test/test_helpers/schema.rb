module TestHelpers
  module Schema
    def setup
      super
      schema = ShopifyCli::AdminAPI::Schema[JSON.parse(File.read(File.join(ShopifyCli::ROOT, "test/fixtures/shopify_schema.json")))]
      ShopifyCli::AdminAPI::Schema.stubs(:get).returns(schema)
    end
  end
end
