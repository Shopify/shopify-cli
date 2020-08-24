# frozen_string_literal: true
module Theme
  module Commands
    class Pull < ShopifyCli::Command
      options do |parser, flags|
        parser.on('--store=STORE') { |url| flags[:store] = url }
        parser.on('--password=PASSWORD') { |p| flags[:password] = p }
        parser.on('--themeid=THEME_ID') { |id| flags[:themeid] = id }
      end

      def call(args, _name)
        form = Forms::Pull.ask(@ctx, args, options.flags)
        return @ctx.puts(self.class.help) if form.nil?

        build(form.store, form.password, form.themeid)
        ShopifyCli::Project.write(@ctx,
                                  project_type: 'theme',
                                  organization_id: nil)

        @ctx.done(@ctx.message('theme.pull.pulled', form.store))
      end

      def self.help
        ShopifyCli::Context.message('theme.pull.help', ShopifyCli::TOOL_NAME)
      end

      private

      def build(store, password, themeid)
        CLI::UI::Frame.open(@ctx.message('theme.checking_themekit')) do
          Themekit.ensure_themekit_installed(@ctx)
        end

        CLI::UI::Frame.open(@ctx.message('theme.pull.pull')) do
          unless Themekit.pull(@ctx, store: store, password: password, themeid: themeid)
            @ctx.abort(@ctx.message('theme.pull.failed'))
          end
        end
      end
    end
  end
end
