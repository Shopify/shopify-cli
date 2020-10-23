# frozen_string_literal: true
require 'project_types/theme/test_helper'

module Theme
  module Commands
    module GenerateTests
      class EnvTest < MiniTest::Test
        include TestHelpers::FakeFS

        resp = [200, { "themes" =>
                 [{ "id" => 2468, "name" => "my_theme" },
                  { "id" => 1357, "name" => "your_theme" }] }]
        THEMES = resp[1]['themes'].map { |theme| [theme['name'], theme['id']] }.to_h

        CONFIG = { "development" =>
                   { "password" => "boop",
                     "theme_id" => "2468",
                     "store" => "shop.myshopify.com" } }

        def test_prompts_for_credentials
          File.write('config.yml', CONFIG.to_yaml)
          context = ShopifyCli::Context.new

          CLI::UI::Prompt.expects(:ask)
            .with(context.message('theme.generate.env.ask_store_default', 'shop.myshopify.com'))
            .returns('office.myshopify.com')

          CLI::UI::Prompt.expects(:ask)
            .with(context.message('theme.generate.env.ask_password_default', 'boop'))
            .returns('beep')

          Themekit.expects(:query_themes)
            .with(context, store: 'office.myshopify.com', password: 'beep')
            .returns(THEMES)
          CLI::UI::Prompt.expects(:ask)
            .with(context.message('theme.generate.env.ask_theme'))
            .returns('2468')

          Themekit.expects(:generate_env)
            .with(context,
                  password: 'beep',
                  themeid: '2468',
                  store: 'office.myshopify.com',
                  env: nil)
            .returns(true)

          command = Theme::Commands::Generate::Env.new(context)
          command.call
        end

        def test_can_use_default_shop_and_password
          File.write('config.yml', CONFIG.to_yaml)
          context = ShopifyCli::Context.new

          CLI::UI::Prompt.expects(:ask)
            .with(context.message('theme.generate.env.ask_store_default', 'shop.myshopify.com'))
            .returns('')

          CLI::UI::Prompt.expects(:ask)
            .with(context.message('theme.generate.env.ask_password_default', 'boop'))
            .returns('')

          Themekit.expects(:query_themes)
            .with(context, store: 'shop.myshopify.com', password: 'boop')
            .returns(THEMES)
          CLI::UI::Prompt.expects(:ask)
            .with(context.message('theme.generate.env.ask_theme'))
            .returns('2468')

          Themekit.expects(:generate_env)
            .with(context,
                  password: 'boop',
                  themeid: '2468',
                  store: 'shop.myshopify.com',
                  env: nil)
            .returns(true)

          command = Theme::Commands::Generate::Env.new(context)
          command.call
        end

        def test_can_provide_credentials_with_flags
          File.write('config.yml', CONFIG.to_yaml)
          context = ShopifyCli::Context.new

          CLI::UI::Prompt.expects(:ask)
            .with(context.message('theme.generate.env.ask_store_default', 'shop.myshopify.com'))
            .never

          CLI::UI::Prompt.expects(:ask)
            .with(context.message('theme.generate.env.ask_password_default', 'boop'))
            .never

          Themekit.expects(:query_themes)
            .with(context, store: 'shop.myshopify.com', password: 'boop')
            .never
          CLI::UI::Prompt.expects(:ask)
            .with(context.message('theme.generate.env.ask_theme'))
            .never

          Themekit.expects(:generate_env)
            .with(context,
                  password: 'beep',
                  themeid: '2468',
                  store: 'office.myshopify.com',
                  env: nil)
            .returns(true)

          command = Theme::Commands::Generate::Env.new(context)
          command.options.flags[:store] = 'office.myshopify.com'
          command.options.flags[:password] = 'beep'
          command.options.flags[:themeid] = '2468'
          command.call
        end

        def test_can_use_different_env
          File.write('config.yml', CONFIG.to_yaml)
          context = ShopifyCli::Context.new

          CLI::UI::Prompt.expects(:ask)
            .with(context.message('theme.generate.env.ask_store_default', 'shop.myshopify.com'))
            .returns('')

          CLI::UI::Prompt.expects(:ask)
            .with(context.message('theme.generate.env.ask_password_default', 'boop'))
            .returns('')

          Themekit.expects(:query_themes)
            .with(context, store: 'shop.myshopify.com', password: 'boop')
            .returns(THEMES)
          CLI::UI::Prompt.expects(:ask)
            .with(context.message('theme.generate.env.ask_theme'))
            .returns('2468')

          Themekit.expects(:generate_env)
            .with(context,
                  password: 'boop',
                  themeid: '2468',
                  store: 'shop.myshopify.com',
                  env: 'test')
            .returns(true)

          command = Theme::Commands::Generate::Env.new(context)
          command.options.flags[:env] = 'test'
          command.call
        end

        def test_not_allow_empty_if_no_config
          context = ShopifyCli::Context.new

          CLI::UI::Prompt.expects(:ask)
            .with(context.message('theme.generate.env.ask_store'), allow_empty: false)
            .returns('shop.myshopify.com')

          CLI::UI::Prompt.expects(:ask)
            .with(context.message('theme.generate.env.ask_password'), allow_empty: false)
            .returns('boop')

          Themekit.expects(:query_themes)
            .with(context, store: 'shop.myshopify.com', password: 'boop')
            .returns(THEMES)
          CLI::UI::Prompt.expects(:ask)
            .with(context.message('theme.generate.env.ask_theme'))
            .returns('2468')

          Themekit.expects(:generate_env)
            .with(context,
                  password: 'boop',
                  themeid: '2468',
                  store: 'shop.myshopify.com',
                  env: nil)
            .returns(true)

          command = Theme::Commands::Generate::Env.new(context)
          command.call
        end
      end
    end
  end
end
