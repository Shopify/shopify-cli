# frozen_string_literal: true
require 'project_types/theme/test_helper'

module Theme
  module Commands
    class PullTest < MiniTest::Test
      include TestHelpers::FakeUI

      SHOPIFYCLI_FILE = <<~CLI
        ---
        project_type: theme
        organization_id: 0
      CLI

      def test_can_pull_theme
        FakeFS do
          context = ShopifyCli::Context.new
          ShopifyCli::Project.expects(:has_current?).returns(false).twice

          Theme::Forms::Pull.expects(:ask)
            .with(context, [], {})
            .returns(Theme::Forms::Pull.new(context, [], { store: 'shop.myshopify.com',
                                                           password: 'boop',
                                                           themeid: '2468',
                                                           name: 'my_theme',
                                                           env: nil }))

          Themekit.expects(:ensure_themekit_installed).with(context)
          context.expects(:dir_exist?).with('my_theme').returns(false)
          Themekit.expects(:pull)
            .with(context, store: 'shop.myshopify.com', password: 'boop', themeid: '2468', env: nil)
            .returns(true)
          context.expects(:done).with(context.message('theme.pull.pulled',
                                                      'my_theme',
                                                      'shop.myshopify.com',
                                                      File.join(context.root, 'my_theme')))

          Theme::Commands::Pull.new(context).call([], 'pull')
          assert_equal SHOPIFYCLI_FILE, File.read(".shopify-cli.yml")
        end
      end

      def test_can_specify_env
        FakeFS do
          context = ShopifyCli::Context.new
          ShopifyCli::Project.expects(:has_current?).returns(false).twice

          Theme::Forms::Pull.expects(:ask)
            .with(context, [], { env: 'test' })
            .returns(Theme::Forms::Pull.new(context, [], { store: 'shop.myshopify.com',
                                                           password: 'boop',
                                                           themeid: '2468',
                                                           name: 'my_theme',
                                                           env: 'test' }))

          Themekit.expects(:ensure_themekit_installed).with(context)
          context.expects(:dir_exist?).with('my_theme').returns(false)
          Themekit.expects(:pull)
            .with(context, store: 'shop.myshopify.com', password: 'boop', themeid: '2468', env: 'test')
            .returns(true)
          context.expects(:done).with(context.message('theme.pull.pulled',
                                                      'my_theme',
                                                      'shop.myshopify.com',
                                                      File.join(context.root, 'my_theme')))

          command = Theme::Commands::Pull.new(context)
          command.options.flags[:env] = 'test'
          command.call([], 'pull')

          assert_equal SHOPIFYCLI_FILE, File.read(".shopify-cli.yml")
        end
      end

      def test_aborts_if_inside_project
        FakeFS do
          context = ShopifyCli::Context.new
          ShopifyCli::Project.expects(:has_current?).returns(true)

          Theme::Forms::Pull.expects(:ask).with(context, [], {}).never
          Themekit.expects(:ensure_themekit_installed).with(context).never
          context.expects(:dir_exist?).with('my_theme').never
          Themekit.expects(:pull)
            .with(context, store: 'shop.myshopify.com', password: 'boop', themeid: '2468', env: nil)
            .never

          assert_raises CLI::Kit::Abort do
            Theme::Commands::Pull.new(context).call([], 'pull')
          end
        end
      end

      def test_aborts_if_duplicate_directory
        FakeFS do
          context = ShopifyCli::Context.new
          ShopifyCli::Project.expects(:has_current?).returns(false)

          Theme::Forms::Pull.expects(:ask)
            .with(context, [], {})
            .returns(Theme::Forms::Pull.new(context, [], { store: 'shop.myshopify.com',
                                                           password: 'boop',
                                                           themeid: '2468',
                                                           name: 'my_theme',
                                                           env: nil }))

          Themekit.expects(:ensure_themekit_installed).with(context)
          context.expects(:dir_exist?).with('my_theme').returns(true)
          Themekit.expects(:pull)
            .with(context, store: 'shop.myshopify.com', password: 'boop', themeid: '2468', env: nil)
            .never

          assert_raises CLI::Kit::Abort do
            Theme::Commands::Pull.new(context).call([], 'pull')
          end
        end
      end

      def test_aborts_if_invalid_credentials
        FakeFS do
          context = ShopifyCli::Context.new
          ShopifyCli::Project.expects(:has_current?).returns(false)

          Theme::Forms::Pull.expects(:ask)
            .with(context, [], {})
            .returns(Theme::Forms::Pull.new(context, [], { store: 'shop.myshopify.com',
                                                           password: 'merp',
                                                           themeid: '1357',
                                                           name: 'your_theme',
                                                           env: nil }))

          Themekit.expects(:ensure_themekit_installed).with(context)
          context.expects(:dir_exist?).with('your_theme').returns(false)
          Themekit.expects(:pull)
            .with(context, store: 'shop.myshopify.com', password: 'merp', themeid: '1357', env: nil)
            .returns(false)

          assert_raises CLI::Kit::Abort do
            Theme::Commands::Pull.new(context).call([], 'pull')
          end
        end
      end
    end
  end
end
