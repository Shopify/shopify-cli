# typed: false
# frozen_string_literal: true
module TestHelpers
  module FakeFS
    def setup
      super
      ::FakeFS.clear!
      ::FakeFS.activate!
      @fake_fs_active = true
    end

    def teardown
      unless @fake_fs_active
        raise "FakeFS `teardown` was called but `setup` wasn't. You may be missing a call to `super`"
      end
      ::FakeFS.deactivate!
      @fake_fs_active = nil
      super
    end
  end
end

module FakeFS
  class File
    def self.binwrite(*args)
      File.write(*args, mode: "wb:ASCII-8BIT")
    end
  end
end
