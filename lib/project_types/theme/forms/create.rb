module Theme
  module Forms
    class Create < ShopifyCli::Form
      attr_accessor :name
      flag_arguments :title, :password, :store

      def ask
        self.store ||= CLI::UI::Prompt.ask("Store domain: ")
        ctx.puts("To create a new theme, we need to connect with a private app. Visit {{underline:#{self.store}/admin/apps/private}} to fetch the password. If you create a new private app, ensure that it has Read and Write Theme access.")
        self.password ||= CLI::UI::Prompt.ask("Password: ")
        self.title ||= CLI::UI::Prompt.ask("Title: ")
        self.name = self.title.downcase.split(" ").join("_")
      end
    end
  end
end
