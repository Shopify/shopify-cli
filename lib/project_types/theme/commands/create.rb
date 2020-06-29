# frozen_string_literal: true
module Theme
  module Commands
    class Create < ShopifyCli::SubCommand
      # prerequisite_task :ensure_themekit_installed # doesn't work

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
      end

      def self.help
      end

      private

      def build(name, password, store)
        unless name == "" || password == "" || store == ""
          Dir.mkdir(name)
          Dir.chdir(name)
        end

        CLI::UI::Frame.open(@ctx.message('create.creating_theme', name)) do
          unless Themekit.create(@ctx, name: name, password: password, store: store) # this one has continuous output
            @ctx.abort('error')
          end
          # out, err, stat = Themekit.create(@ctx, name: name, password: password, store: store)
          # @ctx.puts out
          # unless stat
          #   CLI::UI::Frame.divider("error")
          #   @ctx.puts(err)
          # end
        end
        @ctx.root = File.join(@ctx.root, name)
      end
    end
  end
end
