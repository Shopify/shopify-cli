# frozen_string_literal: true
require "tmpdir"
require "fileutils"

module TestHelpers
  module TemporaryDirectory
    def setup
      super
      @tmp_dir = Dir.mktmpdir
    end

    def teardown
      FileUtils.rm_rf(@tmp_dir) if Dir.exist?(@tmp_dir)
      super
    end
  end
end
