module ShopifyCli
  module Helpers
    class Node
      include SmartProperties
      property :ctx, accepts: ShopifyCli::Context, required: true

      class << self
        def version(ctx)
          require 'semantic/semantic'
          out, _ = ctx.capture2('node', '-v')
          version = out.delete!('v')
          Semantic::Version.new(version)
        end
      end
    end
  end
end
