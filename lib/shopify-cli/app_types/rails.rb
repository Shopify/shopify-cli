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
          KEYS
        end

        def description
          'rails embedded app'
        end

        def serve_command(_ctx)
          "PORT=#{ShopifyCli::Tasks::Tunnel::PORT} bin/rails server"
        end

        def open(ctx)
          ctx.system('open', "#{ctx.project.env.host}/login?shop=#{ctx.project.env.shop}")
        end
      end

      def build
        Gem.install(ctx, 'rails')
        Gem.install(ctx, 'bundler')
        CLI::UI::Frame.open("Generating new rails app in #{name}...") do
          ctx.system(Gem.binary_path_for(ctx, 'rails'), 'new', name)
        end
        CLI::UI::Frame.open("Adding shopify_app gem...") do
          ctx.system('echo', '"gem \'shopify_app\'"', '>>', 'Gemfile')
        end
        CLI::UI::Frame.open("Running bundle install...") do
          ctx.system(Gem.binary_path_for(ctx, 'bundle'), 'install', chdir: ctx.root)
        end
        api_key = CLI::UI.ask('What is your Shopify API Key')
        api_secret = CLI::UI.ask('What is your Shopify API Secret')
        CLI::UI::Frame.open("Running shopfiy_app generator...") do
          ctx.system(
            Gem.binary_path_for(ctx, 'rails'),
            'generate',
            'shopify_app', "--api_key #{api_key}", "--secret #{api_secret}"
          )
        end
        ShopifyCli::Finalize.request_cd(name)
        puts CLI::UI.fmt(post_clone)
      end
    end
  end
end
