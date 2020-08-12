module Theme
  class Themekit
    THEMEKIT = File.join(ShopifyCli.cache_dir, "themekit")

    class << self
      def create(ctx, password:, store:, name:)
        stat = ctx.system(THEMEKIT,
                          "new",
                          "--password=#{password}",
                          "--store=#{store}",
                          "--name=#{name}")
        stat.success?
      end

      def serve(ctx)
        out, stat = ctx.capture2e(THEMEKIT, "open")
        ctx.puts(out)
        ctx.abort(ctx.message('theme.serve.open_fail')) unless stat.success?

        ctx.system(THEMEKIT, "watch")
      end

      def ensure_themekit_installed(ctx)
        Tasks::EnsureThemekitInstalled.call(ctx)
      end
    end
  end
end
