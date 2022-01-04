# typed: ignore
module Theme
  module Forms
    class Select < ShopifyCLI::Form
      attr_accessor :theme
      flag_arguments :root, :title, :exclude_roles, :include_foreign_developments

      def ask
        self.theme = CLI::UI::Prompt.ask(title, allow_empty: false) do |handler|
          themes.each do |theme|
            next if exclude_roles&.include?(theme.role)
            next if !include_foreign_developments && theme.foreign_development?
            handler.option("#{theme.name} #{theme_tags(theme)}") { theme }
          end
        end
      end

      private

      def themes
        @themes ||= ShopifyCLI::Theme::Theme.all(@ctx, root: root)
          .sort_by { |theme| theme_sort_order(theme) }
      end

      def theme_sort_order(theme)
        case theme.role
        when "live"
          0
        when "unpublished"
          1
        when "development"
          2
        else
          3
        end
      end

      def theme_tags(theme)
        color = case theme.role
        when "live"
          "green"
        when "unpublished"
          "yellow"
        when "development"
          "blue"
        else
          "italic"
        end

        tags = ["{{#{color}:[#{theme.role}]}}"]

        if theme.current_development?
          tags << "{{cyan:[yours]}}}}"
        end

        tags.join(" ")
      end
    end
  end
end
