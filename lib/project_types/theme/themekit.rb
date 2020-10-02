module Theme
  class Themekit
    THEMEKIT = File.join(ShopifyCli.cache_dir, "themekit")

    class << self
      def create(ctx, password:, store:, name:)
        stat = ctx.system(THEMEKIT,
                          'new',
                          "--password=#{password}",
                          "--store=#{store}",
                          "--name=#{name}")
        stat.success?
      end

      def deploy(ctx)
        unless push(ctx)
          ctx.abort(ctx.message('theme.deploy.push_fail'))
        end
        ctx.done(ctx.message('theme.deploy.info.pushed'))

        stat = ctx.system(THEMEKIT, 'publish')
        stat.success?
      end

      def ensure_themekit_installed(ctx)
        Tasks::EnsureThemekitInstalled.call(ctx)
      end

      def pull(ctx, store:, password:, themeid:)
        stat = ctx.system(THEMEKIT,
                          "get",
                          "--store=#{store}",
                          "--password=#{password}",
                          "--themeid=#{themeid}")
        stat.success?
      end

      def push(ctx, files: nil, flags: nil, remove: false)
        command = [THEMEKIT]
        command << (remove ? 'remove' : 'deploy')
        (command << flags << files).flatten!

        stat = ctx.system(command.join(' '))
        stat.success?
      end

      def serve(ctx, env:)
        command = [THEMEKIT, 'open']
        if env
          command << '--env=' + env
        end

        out, stat = ctx.capture2e(command.join(' '))
        ctx.puts(out)
        ctx.abort(ctx.message('theme.serve.open_fail')) unless stat.success?

        ctx.system(THEMEKIT, 'watch')
      end
    end
  end
end
