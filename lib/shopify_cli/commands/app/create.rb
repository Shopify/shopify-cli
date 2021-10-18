module ShopifyCLI
  module Commands
    class App
      class Create < ShopifyCLI::Command::AppSubCommand
        options do |parser, flags|
          parser.on("--type=TYPE") do |h|
            flags[:type] = h.gsub('"', "")
          end
        end

        def call(*)
          type = options.flags[:type]
          case type
          when "rails"
            # TODO
          when "php"
            # TODO
          when "node"
            # TODO
          when nil
            message = @ctx.message(
              "core.app.create.invalid_type",
              type,
            )
            raise ShopifyCLI::Abort, message
          end
        end

        def self.help
          ShopifyCLI::Context.message("core.app.create.help", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
        end
      end
    end
  end
end
