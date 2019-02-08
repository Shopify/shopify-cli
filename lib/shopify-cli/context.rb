# frozen_string_literal: true
require 'shopify-cli'

module ShopifyCli
  class Context
    def initialize
      @env = ($original_env || ENV).clone
    end

    def getenv(name)
      v = @env[name]
      v == '' ? nil : v
    end

    def method_missing(method, *args)
      if CLI::Kit::System.respond_to?(method)
        CLI::Kit::System.send(method, *args)
      else
        super
      end
    end
  end
end
