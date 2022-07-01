# frozen_string_literal: true

require "pathname"

module ShopifyCLI
  module Theme
    module DevServer
      # Errors
      Error = Class.new(StandardError)
      AddressBindingError = Class.new(Error)

      class DevServerCommon
        class << self
          attr_accessor :ctx
        end
      end
    end
  end
end
