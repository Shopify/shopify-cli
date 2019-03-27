# frozen_string_literal: true
module TestHelpers
  module FakeFS
    def setup
      ::FakeFS.activate!
      super
    end

    def teardown
      ::FakeFS.deactivate!
      super
    end
  end
end
