# frozen_string_literal: true
require 'shopify_cli'

module ShopifyCli
  class SubCommand < Command
    class << self
      def call(args, command_name)
        cmd = new
        cmd.ctx = @ctx
        cmd.options = Options.new
        cmd.options.parse(@_options, args)
        cmd.call(args, command_name)
      end
    end
  end
end
