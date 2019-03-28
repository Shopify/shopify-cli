# frozen_string_literal: true
module TestHelpers
  module Context
    include TestHelpers::FakeFS

    def setup
      @context = TestHelpers::FakeContext.new
      @context.root = Dir.mktmpdir
      super
    end

    def teardown
      @context = nil
      super
    end
  end
end
