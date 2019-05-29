require 'fileutils'

module ShopifyCli
  class Context
    module FileSystem
      def write(fname, content)
        File.write(File.join(root, fname), content)
      end

      def rm_r(*args)
        FileUtils.rm_r(*args)
      end
    end
  end
end
