module ShopifyCli
  module Helpers
    module Git
      class << self
        GIT_SHA_PATTERN = %r{^[a-f0-9]{40}$}

        def exec(*args, dir: Dir.pwd, default: nil, ctx: Context.new)
          args = %w(git) + args
          out, _, stat = ctx.capture3(*args, chdir: dir)
          return default unless stat.success?
          out.chomp
        end

        def sha(dir: Dir.pwd, ctx: Context.new)
          rev_parse('HEAD', dir: dir, ctx: ctx)
        end

        private

        def rev_parse(*args, dir: nil, ctx: Context.new)
          exec('rev-parse', *args, dir: dir, ctx: ctx)
        end
      end
    end
  end
end
