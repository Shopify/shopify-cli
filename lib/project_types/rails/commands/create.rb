# frozen_string_literal: true
module Rails
  module Commands
    class Create < ShopifyCli::SubCommand
      USER_AGENT_CODE = <<~USERAGENT
        module ShopifyAPI
          class Base < ActiveResource::Base
            self.headers['User-Agent'] << " | ShopifyApp/\#{ShopifyApp::VERSION} | Shopify App CLI"
          end
        end
      USERAGENT

      INVALID_RUBY_VERSION = <<~MSG
        This project requires a ruby version ~> 2.4.
        See {{underline:https://github.com/Shopify/shopify-app-cli/blob/master/docs/installing-ruby.md}}
        for our recommended method of installing ruby.
      MSG

      options do |parser, flags|
        parser.on('--title=TITLE') { |t| flags[:title] = t }
        parser.on('--organization_id=ID') { |url| flags[:organization_id] = url }
        parser.on('--shop_domain=MYSHOPIFYDOMAIN') { |url| flags[:shop_domain] = url }
      end

      def call(args, _name)
        form = Forms::Create.ask(@ctx, args, options.flags)
        return @ctx.puts(self.class.help) if form.nil?

        @ctx.error(INVALID_RUBY_VERSION) unless Ruby.version(@ctx).satisfies?('~>2.4')

        build(form.name)
        set_custom_ua
        ShopifyCli::Project.write(@ctx, 'rails')

        ShopifyCli::Finalize.request_cd(form.name)

        api_client = ShopifyCli::Tasks::CreateApiClient.call(
          @ctx,
          org_id: form.organization_id,
          title: form.title,
          app_url: 'https://shopify.github.io/shopify-app-cli/getting-started',
        )

        ShopifyCli::Helpers::EnvFile.new(
          api_key: api_client["apiKey"],
          secret: api_client["apiSecretKeys"].first["secret"],
          shop: form.shop_domain,
          scopes: 'write_products,write_customers,write_draft_orders',
        ).write(@ctx)

        partners_url = "https://partners.shopify.com/#{form.organization_id}/apps/#{api_client['id']}"

        @ctx.puts("{{v}} {{green:#{form.title}}} was created in your Partner" \
                  " Dashboard " \
                  "{{underline:#{partners_url}}}")
        @ctx.puts("{{*}} Run {{cyan:shopify serve}} to start a local server")
        @ctx.puts("{{*}} Then, visit {{underline:#{partners_url}/test}} to install" \
                  " {{green:#{form.title}}} on your Dev Store")
      end

      def self.help
        <<~HELP
        {{cyan:shopify create rails}}: Creates a ruby on rails app.
          Usage: {{command:#{ShopifyCli::TOOL_NAME} create rails}}
          Options:
            {{command:--title=TITLE}} App project title. Any string.
            {{command:--app_url=APPURL}} App project URL. Must be valid URL.
            {{command:--organization_id=ID}} App project Org ID. Must be existing org ID.
            {{command:--shop_domain=MYSHOPIFYDOMAIN }} Test store URL. Must be existing test store.
        HELP
      end

      private

      def build(name)
        install_gem('rails')
        CLI::UI::Frame.open("Installing bundler…") do
          install_gem('bundler', '~>1.0')
          install_gem('bundler', '~>2.0')
        end

        CLI::UI::Frame.open("Generating new rails app project in #{name}...") do
          syscall(%W(rails new --skip-spring #{name}))
        end

        @ctx.root = File.join(@ctx.root, name)

        @ctx.puts("{{v}} Adding shopify_app gem…")
        File.open(File.join(@ctx.root, 'Gemfile'), 'a') do |f|
          f.puts "\ngem 'shopify_app', '>=11.3.0'"
        end
        CLI::UI::Frame.open("Running bundle install...") do
          syscall(%w(bundle install))
        end

        CLI::UI::Frame.open("Running shopfiy_app generator...") do
          begin
            syscall(%w(spring stop))
          rescue
          end
          syscall(%w(rails generate shopify_app))
        end

        CLI::UI::Frame.open('Running migrations…') do
          syscall(%w(rails db:migrate RAILS_ENV=development))
        end
      end

      def set_custom_ua
        ua_path = File.join('config', 'initializers', 'user_agent.rb')
        @ctx.write(ua_path, USER_AGENT_CODE)
      end

      def syscall(args)
        args[0] = Gem.binary_path_for(@ctx, args[0])
        @ctx.system(*args, chdir: @ctx.root)
      end

      def install_gem(name, version = nil)
        Gem.install(@ctx, name, version)
      end
    end
  end
end

