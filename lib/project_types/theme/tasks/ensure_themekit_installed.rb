module Theme
  module Tasks
    class EnsureThemekitInstalled < ShopifyCli::Task
      URL = 'https://shopify-themekit.s3.amazonaws.com/releases/latest.json'
      OSMAP = {
        mac: 'darwin-amd64',
        linux: 'linux-amd64',
        windows: 'windows-amd64',
      }
      VERSION_CHECK_INTERVAL = 604800
      VERSION_CHECK_SECTION = 'themekitversioncheck'
      LAST_CHECKED_AT_FIELD = 'last_checked_at'

      def call(ctx)
        _out, stat = ctx.capture2e(Themekit::THEMEKIT)
        unless stat.success?
          require 'json'
          require 'fileutils'
          require 'digest'
          require 'open-uri'

          begin
            begin
              releases = JSON.parse(Net::HTTP.get(URI(URL)))
              release = releases["platforms"].find { |r| r["name"] == OSMAP[ctx.os] }
            rescue
              ctx.abort(ctx.message('theme.tasks.ensure_themekit_installed.errors.releases_fail'))
            end

            ctx.puts(ctx.message('theme.tasks.ensure_themekit_installed.downloading', releases['version']))
            _out, stat = ctx.capture2e('curl', '-o', Themekit::THEMEKIT, release["url"])
            ctx.abort(ctx.message('theme.tasks.ensure_themekit_installed.errors.write_fail')) unless stat.success?

            ctx.puts(ctx.message('theme.tasks.ensure_themekit_installed.verifying'))
            if Digest::MD5.file(Themekit::THEMEKIT) == release['digest']
              FileUtils.chmod("+x", Themekit::THEMEKIT)
              ctx.puts(ctx.message('theme.tasks.ensure_themekit_installed.successful'))
            else
              ctx.abort(ctx.message('theme.tasks.ensure_themekit_installed.errors.digest_fail'))
            end
          rescue StandardError, ShopifyCli::Abort => e
            FileUtils.rm(Themekit::THEMEKIT) if File.exist?(Themekit::THEMEKIT)
            raise e
          end
        end

        if (time_of_last_check + VERSION_CHECK_INTERVAL) < (now = Time.now.to_i)
          unless Themekit.update(ctx)
            ctx.abort(ctx.message('theme.tasks.ensure_themekit_installed.errors.update_fail'))
          end
          update_time_of_last_check(now)
        end
      end

      private

      def time_of_last_check
        (val = ShopifyCli::Config.get(VERSION_CHECK_SECTION, LAST_CHECKED_AT_FIELD)) ? val.to_i : 0
      end

      def update_time_of_last_check(time)
        ShopifyCli::Config.set(VERSION_CHECK_SECTION, LAST_CHECKED_AT_FIELD, time)
      end
    end
  end
end
