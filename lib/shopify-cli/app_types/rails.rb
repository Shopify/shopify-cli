# frozen_string_literal: true
require 'shopify_cli'

module ShopifyCli
  module AppTypes
    class Rails < AppType
      include ShopifyCli::Helpers

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
          'rails embedded app'
        end

        def generate
          {
            page: NotImplementedError,
            billing_recurring: NotImplementedError,
            billing_one_time: NotImplementedError,
            webhook: NotImplementedError,
          }
        end

        def serve_command(_ctx)
          "PORT=#{ShopifyCli::Tasks::Tunnel::PORT} bin/rails server"
        end

        def open(ctx)
          ctx.system('open', "#{ctx.project.env.host}/login?shop=#{ctx.project.env.shop}")
        end
      end

      def build(name)
        Gem.install(ctx, 'rails')
        Gem.install(ctx, 'bundler')
        CLI::UI::Frame.open("Generating new rails app project in #{name}...") do
          ctx.system(Gem.binary_path_for(ctx, 'rails'), 'new', name)
        end

        File.open(File.join(ctx.root, 'Gemfile'), 'a') do |f|
          f.puts "\ngem 'shopify_app'"
        end
        ctx.puts("{{green:✔︎}} Adding shopify_app gem…")
        CLI::UI::Frame.open("Installing bundler…") do
          ctx.system('gem', 'install', 'bundler', '-v', '~>1.0', chdir: ctx.root)
          ctx.system('gem', 'install', 'bundler', '-v', '~>2.0', chdir: ctx.root)
        end
        CLI::UI::Frame.open("Running bundle install...") do
          ctx.system(Gem.binary_path_for(ctx, 'bundle'), 'install', chdir: ctx.root)
        end
        CLI::UI::Frame.open("Running shopfiy_app generator...") do
          begin
            ctx.system(Gem.binary_path_for(ctx, 'spring'), 'stop', chdir: ctx.root)
          rescue
            # no op
          end
          ctx.system(
            Gem.binary_path_for(ctx, 'rails'),
            'generate',
            'shopify_app', "--api_key #{ctx.app_metadata[:api_key]}", "--secret #{ctx.app_metadata[:secret]}",
            chdir: ctx.root
          )
        end
        CLI::UI::Frame.open('Running migrations…') do
          ctx.system(Gem.binary_path_for(ctx, 'rails'), 'db:migrate', 'RAILS_ENV=development', chdir: ctx.root)
        end
        ShopifyCli::Finalize.request_cd(name)

        env_file = Helpers::EnvFile.new(
          app_type: self,
          api_key: ctx.app_metadata[:api_key],
          secret: ctx.app_metadata[:secret],
          host: ctx.app_metadata[:host],
          shop: ctx.app_metadata[:shop],
          scopes: 'write_products,write_customers,write_orders',
        )
        env_file.write(ctx, '.env')

        puts CLI::UI.fmt(post_clone)
      end

      def check_dependencies
        Gem.install(ctx, 'rails')
        Gem.install(ctx, 'bundler')
      end
    end
  end
end
