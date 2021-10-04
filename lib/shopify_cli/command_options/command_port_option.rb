require "shopify_cli"

module ShopifyCLI
    module CommandOptions
      module CommandPortOption
        def setHost(options)
          options do |parser, flags|
            parser.on("--host=HOST") do |h|
              flags[:host] = h.gsub('"', "")
            end
          end
        end
        def setPort(options)
          options do |parser, flags|
            parser.on("--port=PORT") { |port| flags[:port] = port }
          end
        end

      end
    end
  end