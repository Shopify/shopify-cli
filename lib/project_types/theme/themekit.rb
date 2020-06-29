module Theme
  class Themekit
    THEMEKIT = File.join(ShopifyCli::CACHE_DIR, "themekit")

    class << self
      def create(ctx, password:, store:, name:)
        ensure_themekit_installed(ctx)
        # out, err, stat = ctx.capture3(THEMEKIT,
        #                                 "new",
        #                                 "--password=#{password}",
        #                                 "--store=#{store}",
        #                                 "--name=#{name}")
        # [out, err == "" ? nil : err, stat.success?]
        stat = ctx.system(THEMEKIT,
                          "new",
                          "--password=#{password}",
                          "--store=#{store}",
                          "--name=#{name}")
        stat.success?
      end

      def ensure_themekit_installed(ctx)
        Tasks::EnsureThemekitInstalled.call(ctx)
      end
    end
  end
end
