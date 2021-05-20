module Theme
  module Forms
    class Select < ShopifyCli::Form
      attr_accessor :theme
      flag_arguments :root, :title, :exclude_roles

      def ask
        self.theme = CLI::UI::Prompt.ask(title, allow_empty: false) do |handler|
          ShopifyCli::Theme::Theme.all(@ctx, root: root).each do |theme|
            next if exclude_roles&.include?(theme.role)
            handler.option("#{theme.name} {{green:[#{theme.role}]}}") { theme }
          end
        end
      end
    end
  end
end
