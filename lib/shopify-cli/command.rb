# frozen_string_literal: true
require 'shopify_cli'

module ShopifyCli
  class Command < CLI::Kit::BaseCommand
    attr_reader :ctx

    def initialize(ctx = nil)
      @ctx = ctx || ShopifyCli::Context.new
    end
  end
end
