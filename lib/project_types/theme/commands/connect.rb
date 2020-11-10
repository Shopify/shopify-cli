# frozen_string_literal: true
module Theme
  module Commands
    class Connect < ShopifyCli::SubCommand
      options do |parser, flags|
        parser.on('--store=STORE') { |url| flags[:store] = url }
        parser.on('--password=PASSWORD') { |p| flags[:password] = p }
        parser.on('--themeid=THEME_ID') { |id| flags[:themeid] = id }
        parser.on('--env=ENV') { |env| flags[:env] = env }
      end

      def call(args, _name)
        if ShopifyCli::Project.has_current?
          @ctx.abort(@ctx.message('theme.connect.inside_project'))
        end

        form = Forms::Connect.ask(@ctx, args, options.flags)
        return @ctx.puts(self.class.help) if form.nil?

        build(form.store, form.password, form.themeid, form.name, form.env)
        ShopifyCli::Project.write(@ctx,
                                  project_type: 'theme',
                                  organization_id: nil)

        @ctx.done(@ctx.message('theme.connect.connected', form.name, form.store, @ctx.root))
      end

      def self.help
        ShopifyCli::Context.message('theme.connect.help', ShopifyCli::TOOL_NAME, ShopifyCli::TOOL_NAME)
      end

      private

      def build(store, password, themeid, name, env)
        CLI::UI::Frame.open(@ctx.message('theme.checking_themekit')) do
          Themekit.ensure_themekit_installed(@ctx)
        end

        if @ctx.dir_exist?(name)
          @ctx.abort(@ctx.message('theme.connect.duplicate'))
        end

        @ctx.mkdir_p(name)
        @ctx.chdir(name)

        CLI::UI::Frame.open(@ctx.message('theme.connect.connect')) do
          unless Themekit.connect(@ctx, store: store, password: password, themeid: themeid, env: env)
            @ctx.chdir('..')
            @ctx.rm_rf(name)
            @ctx.abort(@ctx.message('theme.connect.failed'))
          end
        end
      end
    end
  end
end
