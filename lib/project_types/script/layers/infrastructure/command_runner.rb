# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class CommandRunner
        include SmartProperties

        property! :ctx, accepts: ShopifyCLI::Context

        def call(cmd)
          out, status = ctx.capture2e(cmd)
          raise Errors::SystemCallFailureError.new(out: out.chomp, cmd: cmd) unless status.success?
          out
        end
      end
    end
  end
end
