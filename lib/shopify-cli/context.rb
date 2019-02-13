# frozen_string_literal: true
require 'shopify_cli'

module ShopifyCli
  class Context
    def initialize
      @env = ($original_env || ENV).clone
    end

    def getenv(name)
      v = @env[name]
      v == '' ? nil : v
    end

    def log(*args)
      puts CLI::UI.fmt("{{red:!}} #{args.join}") if @env['DEBUG']
    end

    def method_missing(method, *args)
      if CLI::Kit::System.respond_to?(method)
        CLI::Kit::System.send(method, *args)
      else
        super
      end
    end

    def respond_to_missing?(method, include_private = false)
      if CLI::Kit::System.respond_to?(method)
        true
      else
        super
      end
    end
  end
end
