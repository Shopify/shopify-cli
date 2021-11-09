require "uri"

module Rails
  module Forms
    class Create < ShopifyCLI::Form
      flag_arguments :name, :organization_id, :shop_domain, :type, :db
      VALID_DB_TYPES = ["sqlite3",
                        "mysql",
                        "postgresql",
                        "oracle",
                        "frontbase",
                        "ibm_db",
                        "sqlserver",
                        "jdbcmysql",
                        "jdbcsqlite3",
                        "jdbcpostgresql",
                        "jdbc"]

      def ask
        self.name ||= CLI::UI::Prompt.ask(ctx.message("rails.forms.create.app_name"))
        self.name = format_name
        self.type = ask_type
        res = ShopifyCLI::Tasks::SelectOrgAndShop.call(ctx, organization_id: organization_id, shop_domain: shop_domain)
        self.organization_id = res[:organization_id]
        self.shop_domain = res[:shop_domain]
        self.db = ask_db
      end

      private

      def format_name
        formatted_name = name.downcase.split(" ").join("_")

        if formatted_name.include?("shopify")
          ctx.abort(ctx.message("rails.forms.create.error.invalid_app_name"))
        end

        formatted_name
      end

      def ask_type
        if type.nil?
          return CLI::UI::Prompt.ask(ctx.message("rails.forms.create.app_type.select")) do |handler|
            handler.option(ctx.message("rails.forms.create.app_type.select_public")) { "public" }
            handler.option(ctx.message("rails.forms.create.app_type.select_custom")) { "custom" }
          end
        end

        unless ShopifyCLI::Tasks::CreateApiClient::VALID_APP_TYPES.include?(type)
          ctx.abort(ctx.message("rails.forms.create.error.invalid_app_type", type))
        end
        ctx.puts(ctx.message("rails.forms.create.app_type.selected", type))
        type
      end

      def ask_db
        if db.nil?
          return "sqlite3" unless CLI::UI::Prompt.confirm(ctx.message("rails.forms.create.db.want_select"),
            default: false)
          @db = CLI::UI::Prompt.ask(ctx.message("rails.forms.create.db.select")) do |handler|
            VALID_DB_TYPES.each do |db_type|
              handler.option(ctx.message("rails.forms.create.db.select_#{db_type}")) { db_type }
            end
          end
        end

        unless VALID_DB_TYPES.include?(db)
          ctx.abort(ctx.message("rails.forms.create.error.invalid_db_type", db))
        end
        ctx.puts(ctx.message("rails.forms.create.db.selected", db))
        db
      end
    end
  end
end
