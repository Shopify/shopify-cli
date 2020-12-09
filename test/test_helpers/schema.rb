module TestHelpers
  module Schema
    def setup
      super
      json_data = File.read(File.join(ShopifyCli::ROOT, 'test/fixtures/shopify_schema.json'))
      schema = ShopifyCli::AdminAPI::Schema[JSON.parse(json_data)]
      ShopifyCli::AdminAPI::Schema.stubs(:get).returns(schema)
    end
  end
end
