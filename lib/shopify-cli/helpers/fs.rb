require 'fileutils'

module ShopifyCli
  module Helpers
    module FS
      class << self
        def ensure_file(*path)
          fname = File.join(*path)
          unless File.exist?(fname)
            FileUtils.mkdir_p(File.dirname(fname))
            FileUtils.touch(fname)
          end
          fname
        end

        def ensure_dir(*path)
          fname = File.join(*path)
          FileUtils.mkdir_p(File.dirname(fname)) unless File.exist?(fname)
          fname
        end
      end
    end
  end
end
