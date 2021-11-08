module ShopifyCLI
  module Services
    module App
      module Tunnel
        class StopService < BaseService
          attr_accessor :context

          def initialize(context:)
            @context = context
            super()
          end

          def call
            ShopifyCLI::Tunnel.stop(context)
          end
        end
      end
    end
  end
end
