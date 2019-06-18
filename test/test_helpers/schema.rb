module TestHelpers
  module Schema
    def setup
      super
      ShopifyCli::Tasks::Schema.stubs(:call).returns(schema)
      @context.app_metadata[:schema] = schema
    end

    def schema
      @schema ||= JSON.parse(File.read(File.join(ShopifyCli::ROOT, "test/fixtures/shopify_schema.json")))
    end
  end
end
