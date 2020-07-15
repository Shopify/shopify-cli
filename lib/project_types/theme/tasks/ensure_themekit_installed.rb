module Theme
  module Tasks
    class EnsureThemekitInstalled < ShopifyCli::Task
      FILENAME = File.join(ShopifyCli::CACHE_DIR, "themekit")
      URL = 'https://shopify-themekit.s3.amazonaws.com/releases/latest.json'
      OSMAP = {
        mac: 'darwin-amd64',
        linux: 'linux-amd64',
        windows: 'windows-amd64',
      }

      def call(ctx)
        return if File.exist?(FILENAME)

        require 'json'
        require 'net/http'
        require 'fileutils'
        require 'digest'

        begin
          releases = JSON.parse(Net::HTTP.get(URI(URL)))
          release = releases["platforms"].find { |r| r["name"] == OSMAP[ctx.os] }
          ctx.puts(ctx.message('ensure_themekit_installed.downloading', releases['version']))
          File.write(FILENAME, Net::HTTP.get(URI.parse(release["url"])))
          ctx.puts(ctx.message('ensure_themekit_installed.verifying'))

          if Digest::MD5.file(FILENAME) == release["digest"]
            FileUtils.chmod("+x", FILENAME)
            ctx.puts(ctx.message('ensure_themekit_installed.successful'))
          else
            ctx.puts(ctx.message('ensure_themekit_installed.unsuccessful'))
            FileUtils.rm(FILENAME)
          end
        rescue
          ctx.puts(ctx.message('ensure_themekit_installed.failed'))
        end
      end
    end
  end
end
