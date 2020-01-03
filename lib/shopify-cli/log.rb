require 'shopify_cli'

module ShopifyCli
  class Log < ::File
    TAIL_BUF_LENGTH = 1 << 16

    def initialize(fname, *args)
      Helpers::FS.ensure_dir(fname)
      super(fname, *args)
    end

    def tail(n)
      return [[], 0] if n < 1

      if size < TAIL_BUF_LENGTH
        return [readlines.reverse[0..n - 1], 0]
      end

      seek(-TAIL_BUF_LENGTH, SEEK_END)

      buf = ""
      while buf.count("\n") <= n
        buf = read(TAIL_BUF_LENGTH) + buf
        sk = 2 * -TAIL_BUF_LENGTH
        if sk < -size
          seek(0)
          buf = read(size - buf.size) + buf
          break
        else
          seek(sk, SEEK_CUR)
        end
      end
      ret = buf.split("\n").last(n)
      [ret, ret.join("\n").bytesize + 1]
    end

    def clear(pos)
      truncate(size - pos)
    end
  end
end
