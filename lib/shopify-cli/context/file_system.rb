require 'fileutils'

module ShopifyCli
  class Context
    module FileSystem
      def write(fname, content)
        File.write(File.join(root, fname), content)
      end

      def rename(*args)
        File.rename(*args)
      end

      def rm(*args)
        FileUtils.rm(*args)
      end

      def rm_r(*args)
        FileUtils.rm_r(*args)
      end

      def mkdir_p(*args)
        FileUtils.mkdir_p(*args)
      end
    end
  end
end
