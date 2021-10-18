module ShopifyCLI
  module Services
    module App
      module Tunnel
        class StartService < BaseService
          attr_accessor :context

          def initialize(context:)
            @context = context
            super()
          end

          def call
            ShopifyCLI::Tunnel.start(context)
          end
        end
      end
    end
  end
end
