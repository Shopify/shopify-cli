module Theme
  class Themekit
    THEMEKIT = File.join(ShopifyCli.cache_dir, "themekit")

    class << self
      def create(ctx, password:, store:, name:, env:)
        command = build_command('new', env)
        command << "--password=#{password}"
        command << "--store=#{store}"
        command << "--name=#{name}"

        stat = ctx.system(command.join(' '))
        stat.success?
      end

      def deploy(ctx, env:)
        flags = '--env=' + env if env
        unless push(ctx, flags: flags)
          ctx.abort(ctx.message('theme.deploy.push_fail'))
        end
        ctx.done(ctx.message('theme.deploy.info.pushed'))

        command = build_command('publish', env)
        stat = ctx.system(command.join(' '))
        stat.success?
      end

      def ensure_themekit_installed(ctx)
        Tasks::EnsureThemekitInstalled.call(ctx)
      end

      def pull(ctx, store:, password:, themeid:, env:)
        command = build_command('get', env)
        command << "--password=#{password}"
        command << "--store=#{store}"
        command << "--themeid=#{themeid}"

        stat = ctx.system(command.join(' '))
        stat.success?
      end

      def push(ctx, files: nil, flags: nil, remove: false)
        command = [THEMEKIT, (remove ? 'remove' : 'deploy')]
        (command << flags << files).flatten!

        stat = ctx.system(command.join(' '))
        stat.success?
      end

      def serve(ctx, env:)
        command = build_command('open', env)

        out, stat = ctx.capture2e(command.join(' '))
        ctx.puts(out)
        ctx.abort(ctx.message('theme.serve.open_fail')) unless stat.success?

        command = build_command('watch', env)
        ctx.system(command.join(' '))
      end

      private

      def build_command(action, env)
        command = [THEMEKIT, action]
        command << '--env=' + env if env
      end
    end
  end
end
