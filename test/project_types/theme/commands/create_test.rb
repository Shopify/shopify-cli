# frozen_string_literal: true
require 'project_types/theme/test_helper'

module Theme
  module Commands
    class CreateTest < MiniTest::Test
      include TestHelpers::FakeUI

      SHOPIFYCLI_FILE = <<~CLI
        ---
        project_type: theme
        organization_id: 0
      CLI

      def test_can_create_new_theme
        FakeFS do
          context = ShopifyCli::Context.new
          Themekit.expects(:ensure_themekit_installed).with(context)
          Theme::Forms::Create.expects(:ask)
            .with(context, [], {})
            .returns(Theme::Forms::Create.new(context, [], { password: 'boop',
                                                             store: 'shop.myshopify.com',
                                                             title: 'My Theme',
                                                             name: 'my_theme' }))
          Themekit.expects(:create)
            .with(context, password: 'boop', store: 'shop.myshopify.com', name: 'my_theme')
            .returns(true)
          context.expects(:done).with(context.message('theme.create.info.created',
                                                      'my_theme',
                                                      'shop.myshopify.com',
                                                      File.join('', 'my_theme')))

          Theme::Commands::Create.ctx = context
          Theme::Commands::Create.call([], 'create', nil)

          assert_equal SHOPIFYCLI_FILE, File.read(".shopify-cli.yml")
        end
      end
    end
  end
end
