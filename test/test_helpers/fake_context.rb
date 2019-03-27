module TestHelpers
  class FakeContext < ShopifyCli::Context
    def puts(*args)
    end
  end
end
