# frozen_string_literal: true
module Theme
  module Commands
    class Create < ShopifyCli::SubCommand
      options do |parser, flags|
        parser.on('--name=NAME') { |t| flags[:title] = t }
        parser.on('--password=PASSWORD') { |p| flags[:password] = p }
        parser.on('--store=STORE') { |url| flags[:store] = url }
      end

      def call(args, _name)
        form = Forms::Create.ask(@ctx, args, options.flags)
        return @ctx.puts(self.class.help) if form.nil?

        build(form.name, form.password, form.store)
        ShopifyCli::Project.write(@ctx,
                                  project_type: 'theme',
                                  organization_id: nil) # private apps are different

        @ctx.done(@ctx.message('theme.create.info.created', form.name, form.store, @ctx.root))
      end

      def self.help
        ShopifyCli::Context.message('theme.create.help', ShopifyCli::TOOL_NAME, ShopifyCli::TOOL_NAME)
      end

      private

      def build(name, password, store)
        @ctx.abort(@ctx.message('theme.create.duplicate_theme')) if @ctx.dir_exist?(name)

        CLI::UI::Frame.open(@ctx.message('theme.checking_themekit')) do
          Themekit.ensure_themekit_installed(@ctx)
        end

        @ctx.mkdir_p(name)
        @ctx.chdir(name)

        CLI::UI::Frame.open(@ctx.message('theme.create.creating_theme', name)) do
          unless Themekit.create(@ctx, name: name, password: password, store: store)
            @ctx.chdir('..')
            @ctx.rm_rf(name)
            @ctx.abort(@ctx.message('theme.create.failed'))
          end
        end
      end
    end
  end
end
