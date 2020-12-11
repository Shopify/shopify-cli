module Theme
  class Themekit
    THEMEKIT = File.join(ShopifyCli.cache_dir, "themekit")

    class << self
      def add_flags(flags)
        flags.map do |key, value|
          flag = "--#{key}"
          flag += "=#{value}" if value.is_a?(String)
          flag
        end
      end

      def connect(ctx, store:, password:, themeid:, env:)
        command = build_command('get', env)
        command << "--password=#{password}"
        command << "--store=#{store}"
        command << "--themeid=#{themeid}"

        stat = ctx.system(*command)
        stat.success?
      end

      def create(ctx, password:, store:, name:, env:)
        command = build_command('new', env)
        command << "--password=#{password}"
        command << "--store=#{store}"
        command << "--name=#{name}"

        stat = ctx.system(*command)
        stat.success?
      end

      def deploy(ctx, flags: nil, env:)
        unless push(ctx, flags: flags, env: env)
          ctx.abort(ctx.message('theme.deploy.push_fail'))
        end
        ctx.done(ctx.message('theme.deploy.info.pushed'))

        command = build_command('publish', env)
        (command << flags).compact!
        command.flatten!

        stat = ctx.system(*command)
        stat.success?
      end

      def generate_env(ctx, store:, password:, themeid:, env:)
        command = build_command('configure', env)
        command << "--password=#{password}"
        command << "--store=#{store}"
        command << "--themeid=#{themeid}"

        stat = ctx.system(*command)
        stat.success?
      end

      def push(ctx, files: nil, flags: nil, remove: false, env:)
        action = remove ? 'remove' : 'deploy'
        command = build_command(action, env)

        (command << files << flags).compact!
        command.flatten!

        stat = ctx.system(*command)
        stat.success?
      end

      def query_themes(ctx, store:, password:)
        begin
          resp = ::ShopifyCli::AdminAPI.rest_request(
            ctx,
            shop: store,
            token: password,
            path: "themes.json",
          )
        rescue ShopifyCli::API::APIRequestUnauthorizedError
          ctx.abort(ctx.message('theme.themekit.query_themes.bad_password'))
        rescue StandardError
          ctx.abort(ctx.message('theme.themekit.query_themes.not_connect'))
        end

        resp[1]['themes'].map { |theme| [theme['name'], theme['id']] }.to_h
      end

      def serve(ctx, flags: nil, env:)
        command = build_command('open', env)
        out, stat = ctx.capture2e(*command)
        ctx.puts(out)
        ctx.abort(ctx.message('theme.serve.open_fail')) unless stat.success?

        command = build_command('watch', env)
        (command << flags).compact!
        command.flatten!
        ctx.system(*command)
      end

      def update(ctx)
        command = build_command('update')
        ctx.system(*command)
      end

      private

      def build_command(action, env = nil)
        command = [THEMEKIT, action]
        command << '--no-update-notifier'
        command << "--env=#{env}" if env
        command
      end
    end
  end
end
