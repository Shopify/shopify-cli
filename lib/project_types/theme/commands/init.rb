# frozen_string_literal: true

module Theme
  class Command
    class Init < ShopifyCLI::Command::SubCommand
      recommend_default_ruby_range

      options do |parser, flags|
        parser.on("-u", "--clone-url URL") { |url| flags[:clone_url] = url }
      end

      prerequisite_task :ensure_git_dependency

      DEFAULT_CLONE_URL = "https://github.com/Shopify/dawn.git"

      def call(args, _name)
        name = args.first || ask_name
        clone_url = options.flags[:clone_url] || DEFAULT_CLONE_URL
        clone(clone_url, name)
      end

      def self.help
        ShopifyCLI::Context.message("theme.init.help", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
      end

      private

      def ask_name
        CLI::UI::Prompt.ask(@ctx.message("theme.init.ask_name"))
      end

      def clone(url, name)
        ShopifyCLI::Git.clone(url, name)

        @ctx.root = File.join(@ctx.root, name)

        begin
          @ctx.rm_r(".git")
          @ctx.rm_r(".github")
        rescue Errno::ENOENT => e
          @ctx.debug(e)
        end
      end
    end
  end
end
