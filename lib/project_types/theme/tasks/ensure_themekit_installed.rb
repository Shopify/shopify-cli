module Theme
  module Tasks
    class EnsureThemekitInstalled < ShopifyCli::Task
      def call(ctx)
        @ctx = ctx
        unless system(File.join(ShopifyCli::CACHE_DIR, "theme"), [:out, :err] => File::NULL)
          require 'json'
          require 'net/http'
          require 'fileutils'
          require 'digest'

          url = 'https://shopify-themekit.s3.amazonaws.com/releases/latest.json'
          osmap = {
            mac: 'darwin-amd64',
            linux: 'linux-amd64',
          }

          releases = JSON.parse(Net::HTTP.get(URI(url)))
          release = releases["platforms"].find { |r| r["name"] == osmap[@ctx.os] }
          puts "Downloading Themekit #{releases['version']}"
          File.write(filename, Net::HTTP.get(URI.parse(release["url"])))
          puts "Verifying Download"
          if Digest::MD5.file(filename) == release["digest"]
            FileUtils.chmod("+x", filename)
            puts "Themekit installed successfully"
          else
            puts "Unable to verify download digest"
            FileUtils.rm(filename)
          end
        end
      end

      private

      def filename
        File.join(ShopifyCli::CACHE_DIR, "themekit")
      end
    end
  end
end
