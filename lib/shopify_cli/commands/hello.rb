require "shopify_cli"

module ShopifyCli
  module Commands
    class Hello < ShopifyCli::Command
      options do |parser, flags|
        parser.on("--language=LANGUAGE") { |lang| flags[:lang] = lang }
      end

      def call(args, _name)

        org_id = ShopifyCli::DB.get(:organization_id)
        org = ShopifyCli::PartnersAPI::Organizations.fetch(@ctx, id: org_id) unless org_id.nil?

        command = args.shift
        language = (options.flags[:lang] || nil)

        greeting = if language.nil? || language === 'en'
          "Hello"
        elsif language === 'fr'
          "Bonjour"
        end

        output = if org.nil?
          @ctx.message("core.whoami.not_logged_in", ShopifyCli::TOOL_NAME)
        else
          "#{greeting} #{org["businessName"]}"
        end

        @ctx.puts(output)
      end

      private

    end
  end
end
