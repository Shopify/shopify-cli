# frozen_string_literal: true
require "shopify_cli"

module ShopifyCli
  class SubCommand < Command
    class << self
      def call(args, command_name, parent_command)
        cmd = new(@ctx)
        args = cmd.options.parse(@_options, args[1..-1] || [])
        return call_help(parent_command, command_name) if cmd.options.help
        run_prerequisites

        if command_name == "create"
          @ctx.abort(
            @ctx.message("core.login_prompt", ShopifyCli::TOOL_NAME)
          ) unless ShopifyCli::DB.exists?(:shop)
        end

        cmd.call(args, command_name)
      end
    end
  end
end
