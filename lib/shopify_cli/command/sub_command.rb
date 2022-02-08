# frozen_string_literal: true
require "shopify_cli"

module ShopifyCLI
  class Command
    class SubCommand < Command
      class << self
        def call(args, command_name, parent_command)
          cmd = new(@ctx)
          args = cmd.options.parse(@_options, args || [])
          return call_help(parent_command, command_name) if cmd.options.help
          check_ruby_version
          check_node_version
          run_prerequisites

          cmd.call(args, command_name)
        end
      end
    end
  end
end
