# frozen_string_literal: true
require 'shopify_cli'

module ShopifyCli
  class Command < CLI::Kit::BaseCommand
    attr_writer :ctx
    attr_accessor :options

    class << self
      attr_writer :ctx
      attr_reader :hidden

      def call(args, command_name)
        subcommand, resolved_name = subcommand_registry.lookup_command(args.first)
        if subcommand
          subcommand.ctx = @ctx
          subcommand.call(args, resolved_name, command_name)
        else
          cmd = new
          cmd.ctx = @ctx
          cmd.options = Options.new
          cmd.options.parse(@_options, args)
          return call_help(command_name) if cmd.options.help
          cmd.call(args, command_name)
        end
      end

      def hidden_command
        @hidden = true
      end

      def options(&block)
        @_options = block
      end

      def subcommand(const, cmd, path = nil)
        autoload(const, path) if path
        subcommand_registry.add(->() { const_get(const) }, cmd.to_s)
      end

      def subcommand_registry
        @subcommand_registry ||= CLI::Kit::CommandRegistry.new(
          default: nil,
          contextual_resolver: nil,
        )
      end

      def prerequisite_task(*tasks)
        tasks.each do |task|
          prerequisite_tasks[task] = ShopifyCli::Tasks::Registry[task]
        end
      end

      def prerequisite_tasks
        @prerequisite_tasks ||= {}
      end

      def call_help(*cmds)
        help = Commands::Help.new(@ctx)
        help.call(cmds, nil)
      end
    end

    def initialize(ctx = nil)
      @ctx = ctx || ShopifyCli::Context.new
    end
  end
end
