module TestHelpers
  class FakeContext < ShopifyCli::Context
    attr_accessor :output_captured

    def puts(*args)
      super(*args) if output_captured
    end

    def testing?
      true
    end
  end
end
