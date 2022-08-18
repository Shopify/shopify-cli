module TestHelpers
  class FakeContext < ShopifyCLI::Context
    attr_accessor :output_captured

    def puts(*args)
      super(*args) if output_captured
    end

    ##
    # Do not open the browser on unit tests
    def open_browser_url!(*args)
      open_url!(*args)
    end

    def testing?
      true
    end
  end
end
