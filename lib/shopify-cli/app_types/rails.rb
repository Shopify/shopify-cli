# frozen_string_literal: true
require 'shopify_cli'

module ShopifyCli
  module AppTypes
    class Rails < AppType
      include ShopifyCli::Helpers

      class << self
        def description
          'rails embedded app'
        end

        def generate
          {
            page: NotImplementedError,
            billing_recurring: NotImplementedError,
            billing_one_time: NotImplementedError,
            webhook: 'rails g shopify_app:add_webhook',
          }
        end

        def serve_command(ctx)
          Helpers::Gem.gem_home(ctx)
          "PORT=#{ShopifyCli::Tasks::Tunnel::PORT} bin/rails server"
        end

        def generate_command(selected_type)
          parts = selected_type.downcase.split("_")
          selected_type = parts[0..-2].join("_") + "/" + parts[-1]
          "#{generate[:webhook]} -t #{selected_type} -a #{Project.current.env.host}/webhooks/#{selected_type.downcase}"
        end

        def open_url
          "#{Project.current.env.host}/login?shop=#{Project.current.env.shop}"
        end

        def webhook_location
          "config/webhooks"
        end

        def callback_url
          "/auth/shopify/callback"
        end
      end

      def build(name)
        Gem.install(ctx, 'rails')
        CLI::UI::Frame.open("Installing bundler…") do
          Gem.install(ctx, 'bundler', '~>1.0')
          Gem.install(ctx, 'bundler', '~>2.0')
        end
        CLI::UI::Frame.open("Generating new rails app project in #{name}...") do
          ctx.system(Gem.binary_path_for(ctx, 'rails'), 'new', name)
        end

        File.open(File.join(ctx.root, 'Gemfile'), 'a') do |f|
          f.puts "\ngem 'shopify_app', '>=11.3.0'"
        end
        ctx.puts("{{v}} Adding shopify_app gem…")
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
            'shopify_app',
            chdir: ctx.root
          )
        end
        CLI::UI::Frame.open('Running migrations…') do
          ctx.system(Gem.binary_path_for(ctx, 'rails'), 'db:migrate', 'RAILS_ENV=development', chdir: ctx.root)
        end
        ShopifyCli::Finalize.request_cd(name)

        set_custom_ua
      end

      def check_dependencies
        unless Helpers::Ruby.version(ctx).satisfies?('~>2.4')
          raise ShopifyCli::Abort, invalid_ruby_message
        end
        Gem.install(ctx, 'rails')
        Gem.install(ctx, 'bundler')
      end

      private

      def invalid_ruby_message
        <<~MSG
          This project requires a ruby version ~> 2.4.
          See https://github.com/Shopify/shopify-app-cli/blob/master/docs/installing-ruby.md
          for our recommended method of installing ruby.
        MSG
      end

      # TODO: update once custom UA gets into shopify_app release
      def set_custom_ua
        ua_path = File.join(ctx.root, 'config', 'initializers', 'user_agent.rb')
        ua_code = <<~USERAGENT
          module ShopifyAPI
            class Base < ActiveResource::Base
              self.headers['User-Agent'] << " | ShopifyApp/\#{ShopifyApp::VERSION} | Shopify App CLI"
            end
          end
        USERAGENT
        File.open(ua_path, 'w') { |file| file.puts ua_code }
      end
    end
  end
end
