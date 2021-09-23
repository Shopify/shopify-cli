module ShopifyCli
  module CommandOptions
    module CommandPortOption
      options do |parser, flags|
        parser.on("--port=PORT") { |port| flags[:port] = port }
      end
    end
  end
end
