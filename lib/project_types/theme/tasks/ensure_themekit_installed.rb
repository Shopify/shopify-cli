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
        return if File.exist?(Themekit::THEMEKIT)

        require 'json'
        require 'net/http'
        require 'fileutils'
        require 'digest'

        begin
          releases = JSON.parse(Net::HTTP.get(URI(URL)))
          release = releases["platforms"].find { |r| r["name"] == OSMAP[ctx.os] }
          ctx.puts(ctx.message('ensure_themekit_installed.downloading', releases['version']))
          File.write(Themekit::THEMEKIT, Net::HTTP.get(URI.parse(release["url"])).force_encoding("UTF-8"))
          ctx.puts(ctx.message('ensure_themekit_installed.verifying'))

          if Digest::MD5.file(Themekit::THEMEKIT) == release["digest"]
            FileUtils.chmod("+x", Themekit::THEMEKIT)
            ctx.puts(ctx.message('ensure_themekit_installed.successful'))
          else
            ctx.puts(ctx.message('ensure_themekit_installed.unsuccessful'))
            FileUtils.rm(Themekit::THEMEKIT)
          end
        rescue
          ctx.puts(ctx.message('ensure_themekit_installed.failed'))
          FileUtils.rm(Themekit::THEMEKIT) if File.exist?(Themekit::THEMEKIT)
        end
      end
    end
  end
end
