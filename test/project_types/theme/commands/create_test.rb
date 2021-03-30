# frozen_string_literal: true
require "project_types/theme/test_helper"

module Theme
  module Commands
    class CreateTest < MiniTest::Test
      include TestHelpers::FakeUI

      TEMPLATE_DIRS = Theme::Command::Create::TEMPLATE_DIRS
      SETTINGS_DATA = Theme::Command::Create::SETTINGS_DATA
      SETTINGS_SCHEMA = Theme::Command::Create::SETTINGS_SCHEMA

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
                                                             name: "my_theme" }))
          ShopifyCli::AdminAPI.expects(:get_shop).returns("shop.myshopify.com")

          context.expects(:done).with(context.message("theme.create.info.created",
            "my_theme",
            "shop.myshopify.com",
            File.join(context.root, "my_theme")))

          Theme::Command::Create.new(context).call([], "create")
          assert_equal SHOPIFYCLI_FILE, File.read(".shopify-cli.yml")
          TEMPLATE_DIRS.each { |dir| assert Dir.exist?(dir) }
          assert_equal SETTINGS_DATA, File.read("config/settings_data.json")
          assert_equal SETTINGS_SCHEMA, File.read("config/settings_schema.json")
        end
      end
    end
  end
end
