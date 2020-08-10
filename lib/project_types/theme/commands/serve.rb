# frozen_string_literal: true
module Theme
  module Commands
    class Serve < ShopifyCli::Command
      options do |parser, flags|
        parser.on('--env=ENV') { |env| flags[:env] = env }
      end

      def call(args, _name)
        form = Forms::Serve.ask(@ctx, args, options.flags)
        return @ctx.puts(self.class.help) if form.nil?

        out, stat = @ctx.capture2e(File.join(ShopifyCli.cache_dir, "themekit"),
                       "open",
                       "--env=#{form.env}")
        @ctx.puts(out)
        @ctx.abort('not work') unless stat.success?

        @ctx.system(File.join(ShopifyCli.cache_dir, "themekit"),
                       "watch")
      end

      def self.help
        # ShopifyCli::Context.message('theme.serve.help', ShopifyCli::TOOL_NAME)
      end
    end
  end
end
