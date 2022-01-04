# typed: ignore
module Rails
  class Ruby
    include SmartProperties

    VERSION_STRING = /ruby ([\d\.]+)/

    property :ctx, accepts: ShopifyCLI::Context, required: true

    class << self
      def version(ctx)
        require "semantic/semantic"
        out, _ = ctx.capture2("ruby", "-v")
        Semantic::Version.new(VERSION_STRING.match(out)[1])
      end
    end
  end
end
