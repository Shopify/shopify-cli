module Theme
  module Tasks
    class EnsureThemekitInstalled < ShopifyCli::Task
      URL = 'https://shopify-themekit.s3.amazonaws.com/releases/latest.json'
      OSMAP = {
        mac: 'darwin-amd64',
        linux: 'linux-amd64',
        windows: 'windows-amd64',
      }

      def call(ctx)
        _out, stat = ctx.capture2e(Themekit::THEMEKIT)
        return if stat.success?

        require 'json'
        require 'fileutils'
        require 'digest'
        require 'open-uri'

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
  end
end
