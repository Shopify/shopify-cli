require "shopify_cli"

module ShopifyCli
  module Commands
    class Hello < ShopifyCli::Command
      options do |parser, flags|
        parser.on("--language=LANGUAGE") { |lang| flags[:lang] = lang }
      end

      def call(args, _name)
        command = args.shift
        language = (options.flags[:lang] || nil)
        if language.nil? || language === 'en'
          @ctx.puts("Hello!")
        elsif language === 'fr'
          @ctx.puts("Bonjour!")
        end
      end

      private

    end
  end
end
