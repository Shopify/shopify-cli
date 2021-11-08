module ShopifyCLI
  module Services
    module App
      module Tunnel
        class AuthService < BaseService
          attr_accessor :context, :token

          def initialize(token:, context:)
            @context = context
            @token = token
            super()
          end

          def call
            ShopifyCLI::Tunnel.auth(context, token)
          end
        end
      end
    end
  end
end
