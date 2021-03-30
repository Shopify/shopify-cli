# frozen_string_literal: true
require "project_types/theme/test_helper"

module Theme
  module Commands
    class CreateTest < MiniTest::Test
      include TestHelpers::FakeUI

      SETTINGS_DATA = Theme::Commands::Create::SETTINGS_DATA
      SETTINGS_SCHEMA = Theme::Commands::Create::SETTINGS_SCHEMA

      SHOPIFYCLI_FILE = <<~CLI
        ---
        project_type: theme
        organization_id: 0
      CLI

      def test_can_create_new_theme
        FakeFS do
          context = ShopifyCli::Context.new
          Theme::Forms::Create.expects(:ask)
            .with(context, [], {})
            .returns(Theme::Forms::Create.new(context, [], { title: "My Theme",
                                                             name: "my_theme",
                                                             env: nil }))
          ShopifyCli::AdminAPI.expects(:get_shop).returns("shop.myshopify.com").times(2)
          response = [201, { "theme": { "id": 121253134499 } }]
          ShopifyCli::AdminAPI.expects(:rest_request).returns(response)

          context.expects(:done).with(context.message("theme.create.info.created",
            "my_theme",
            "shop.myshopify.com",
            File.join(context.root, "my_theme")))

          Theme::Commands::Create.new(context).call([], "create")
          assert_equal SHOPIFYCLI_FILE, File.read(".shopify-cli.yml")
          assert_equal SETTINGS_DATA, File.read("config/settings_data.json")
          assert_equal SETTINGS_SCHEMA, File.read("config/settings_schema.json")
        end
      end

      def test_can_specify_env
        skip("until something with env is done")
        FakeFS do
          context = ShopifyCli::Context.new
          Theme::Forms::Create.expects(:ask)
            .with(context, [], { env: "test" })
            .returns(Theme::Forms::Create.new(context, [], { shop: "shop.myshopify.com",
                                                             title: "My Theme",
                                                             env: "test" }))
          Themekit.expects(:create)
            .with(context, password: "boop", store: "shop.myshopify.com", name: "my_theme", env: "test")
            .returns(true)
          context.expects(:done).with(context.message("theme.create.info.created",
            "my_theme",
            "shop.myshopify.com",
            File.join(context.root, "my_theme")))

          command = Theme::Commands::Create.new(context)
          command.options.flags[:env] = "test"
          command.call([], "create")

          assert_equal SHOPIFYCLI_FILE, File.read(".shopify-cli.yml")
        end
      end
    end
  end
end
