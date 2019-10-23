require 'shopify_cli'

module ShopifyCli
  class Log < ::File
    TAIL_BUF_LENGTH = 1 << 16

    def initialize(fname, *args)
      Helpers::FS.ensure_dir(fname)
      super(fname, *args)
    end

    def tail(n)
      return [] if n < 1

      if size < TAIL_BUF_LENGTH
        return readlines.reverse[0..n - 1]
      end

      seek(-TAIL_BUF_LENGTH, SEEK_END)

      buf = ""
      while buf.count("\n") <= n
        buf = read(TAIL_BUF_LENGTH) + buf
        seek(2 * -TAIL_BUF_LENGTH, SEEK_CUR)
      end

      buf.split("\n")[-n..-1]
    end
  end
end
