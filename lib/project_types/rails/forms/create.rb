require 'uri'

module Rails
  module Forms
    class Create < ShopifyCli::Form
      attr_accessor :name
      flag_arguments :title, :organization_id, :shop_domain, :type, :db

      def ask
        self.title ||= CLI::UI::Prompt.ask(ctx.message('rails.forms.create.app_name'))
        self.type = ask_type
        self.name = self.title.downcase.split(" ").join("_")
        self.organization_id ||= organization["id"].to_i
        self.shop_domain ||= ask_shop_domain
        self.db = ask_db
      end

      private

      def ask_type
        if type.nil?
          return CLI::UI::Prompt.ask(ctx.message('rails.forms.create.app_type.select')) do |handler|
            handler.option(ctx.message('rails.forms.create.app_type.select_public')) { 'public' }
            handler.option(ctx.message('rails.forms.create.app_type.select_custom')) { 'custom' }
          end
        end

        unless ShopifyCli::Tasks::CreateApiClient::VALID_APP_TYPES.include?(type)
          ctx.abort(ctx.message('rails.forms.create.error.invalid_app_type', type))
        end
        ctx.puts(ctx.message('rails.forms.create.app_type.selected', type))
        type
      end

      def organizations
        @organizations ||= ShopifyCli::PartnersAPI::Organizations.fetch_all(ctx)
      end

      def organization
        @organization ||= if !organization_id.nil?
          org = ShopifyCli::PartnersAPI::Organizations.fetch(ctx, id: organization_id)
          if org.nil?
            ctx.puts(ctx.message('rails.forms.create.authentication_issue', ShopifyCli::TOOL_NAME))
            ctx.abort(ctx.message('rails.forms.create.error.organization_not_found'))
          end
          org
        elsif organizations.count == 0
          ctx.puts(ctx.message('rails.forms.create.partners_notice'))
          ctx.puts(ctx.message('rails.forms.create.authentication_issue', ShopifyCli::TOOL_NAME))
          ctx.abort(ctx.message('rails.forms.create.error.no_organizations'))
        elsif organizations.count == 1
          ctx.puts(ctx.message('rails.forms.create.organization', organizations.first['businessName']))
          organizations.first
        else
          org_id = CLI::UI::Prompt.ask(ctx.message('rails.forms.create.organization_select')) do |handler|
            organizations.each { |o| handler.option(o['businessName']) { o['id'] } }
          end
          organizations.find { |o| o['id'] == org_id }
        end
      end

      def ask_shop_domain
        valid_stores = organization['stores'].select do |store|
          store['transferDisabled'] == true || store['convertableToPartnerTest'] == true
        end

        if valid_stores.count == 0
          ctx.puts(ctx.message('rails.forms.create.no_development_stores'))
          ctx.puts(ctx.message('rails.forms.create.create_store', organization['id']))
          ctx.puts(ctx.message('rails.forms.create.authentication_issue', ShopifyCli::TOOL_NAME))
        elsif valid_stores.count == 1
          domain = valid_stores.first['shopDomain']
          ctx.puts(ctx.message('rails.forms.create.development_store', domain))
          domain
        else
          CLI::UI::Prompt.ask(
            ctx.message('rails.forms.create.development_store_select'),
            options: valid_stores.map { |s| s['shopDomain'] }
          )
        end
      end

      def ask_db
        if db.nil?
          want_select = CLI::UI::Prompt.ask(ctx.message('rails.forms.create.db.want_select.select')) do |handler|
            handler.option(ctx.message('rails.forms.create.db.want_select.select_no')) { false }
            handler.option(ctx.message('rails.forms.create.db.want_select.select_yes')) { true }
          end

          if want_select
            return CLI::UI::Prompt.ask(ctx.message('rails.forms.create.db.type.select')) do |handler|
              handler.option(ctx.message('rails.forms.create.db.type.select_sqlite')) { 'sqlite' }
              handler.option(ctx.message('rails.forms.create.db.type.select_mysql')) { 'mysql' }
              handler.option(ctx.message('rails.forms.create.db.type.select_pg')) { 'postgresql' }
              handler.option(ctx.message('rails.forms.create.db.type.select_oracle')) { 'oracle' }
              handler.option(ctx.message('rails.forms.create.db.type.select_fb')) { 'frontbase' }
              handler.option(ctx.message('rails.forms.create.db.type.select_ibm')) { 'ibm_db' }
              handler.option(ctx.message('rails.forms.create.db.type.select_sql')) { 'sqlserver' }
              handler.option(ctx.message('rails.forms.create.db.type.select_jdbc_mysql')) { 'jdbcmysql' }
              handler.option(ctx.message('rails.forms.create.db.type.select_jdbc_sqlite')) { 'jdbcsqlite3' }
              handler.option(ctx.message('rails.forms.create.db.type.select_jdbc_pg')) { 'jdbcpostgresql' }
              handler.option(ctx.message('rails.forms.create.db.type.select_jdbc')) { 'jdbc' }
            end
          else
            return 'sqlite3'
          end
        end

        unless ShopifyCli::Tasks::CreateApiClient::VALID_DB_TYPES.include?(db)
          ctx.abort(ctx.message('rails.forms.create.error.invalid_db_type', db))
        end
        ctx.puts(ctx.message('rails.forms.create.db.type.selected', db))
        db
      end
    end
  end
end

