require 'shopify_cli'

module ShopifyCli
  module AppTypes
    class PlayScala < AppType
      class << self
        def env_file
          <<~KEYS
            SHOPIFY_API_KEY={api_key}
            SHOPIFY_API_SECRET_KEY={secret}
            HOST={host}
            SHOP={shop}
            SCOPES={scopes}
          KEYS
        end

        def description
          'Scala Play! Framework app (alpha)'
        end

        def serve_command(ctx)
          host = Project.current.env.host.dup
          host.slice!("https://").slice!("http://")

          set_allowed_host = "-Dplay.filters.hosts.allowed.0=#{host}"
          set_api_key = "-Dshopify.apiKey=#{Project.current.env.api_key}"
          set_api_secret = "-Dshopify.apiSecret=#{Project.current.env.secret}"

          "sbt #{set_allowed_host} #{set_api_key} #{set_api_secret} \"run #{ShopifyCli::Tasks::Tunnel::PORT}\""
        end

        def generate
        end

        def open(ctx)
          ctx.system('open', "#{Project.current.env.host}/unsafe_install?shop=#{Project.current.env.shop}")
        end
      end

      def build(name)
        ShopifyCli::Tasks::Clone.call('git@github.com:fulrich/scalify-play-example.git', name)
        ShopifyCli::Finalize.request_cd(name)

        env_file = Helpers::EnvFile.new(
          api_key: ctx.app_metadata[:api_key],
          secret: ctx.app_metadata[:secret],
          host: ctx.app_metadata[:host],
          shop: ctx.app_metadata[:shop],
          scopes: 'write_products,write_customers,write_draft_orders',
          )
        env_file.write(ctx, self.class.env_file)

        begin
          ctx.rm_r(File.join(ctx.root, '.git'))
          ctx.rm_r(File.join(ctx.root, '.github'))
        rescue Errno::ENOENT => e
          ctx.debug(e)
        end

        puts CLI::UI.fmt(post_clone)
      end

      def check_dependencies
        CLI::UI::Frame.open("Checking Scala Dependencies") do
          check_javac
          check_sbt
        end
      end

      def check_javac
        javac_name = "javac"
        javac_version_command = 'javac -version'
        javac_download_url = 'https://www.oracle.com/technetwork/java/javase/downloads/jdk11-downloads-5066655.html'

        version, stat = ctx.capture2e(javac_version_command)

        ctx.puts("{{green:✔︎}} #{version}")

        error(javac_name, javac_download_url) unless stat.success?
      end

      def check_sbt
        sbt_name = "SBT"
        sbt_version_command = 'sbt sbtVersion'
        sbt_download_url = 'https://www.scala-sbt.org.'

        version, stat = ctx.capture2e(sbt_version_command)
        parsed_version = version.rpartition("]").last.strip

        ctx.puts("{{green:✔︎}} #{sbt_name} #{parsed_version}")

        error(sbt_name, sbt_download_url) unless stat.success?
      end


      def error(dependency_name, download_url)
        raise(ShopifyCli::Abort, "#{dependency_name} is required to create a Scala app project. Download at #{download_url}")
      end
    end
  end
end
