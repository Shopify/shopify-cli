# frozen_string_literal: true
require 'shopify_cli'
require 'shopify-cli/tip_of_the_day'

module ShopifyCli
  class Command < CLI::Kit::BaseCommand
    extend Feature::Set

    attr_writer :ctx
    attr_accessor :options

    class << self
      attr_writer :ctx, :task_registry

      def call(args, command_name)
        call_tip_of_the_day
        subcommand, resolved_name = subcommand_registry.lookup_command(args.first)
        if subcommand
          subcommand.ctx = @ctx
          subcommand.task_registry = @task_registry
          subcommand.call(args, resolved_name, command_name)
        else
          cmd = new(@ctx)
          cmd.options.parse(@_options, args)
          return call_help(command_name) if cmd.options.help
          run_prerequisites
          cmd.call(args, command_name)
        end
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
        @prerequisite_tasks ||= []
        @prerequisite_tasks += tasks
      end

      def run_prerequisites
        (@prerequisite_tasks || []).each { |task| task_registry[task]&.call(@ctx) }
      end

      def task_registry
        @task_registry || ShopifyCli::Tasks::Registry
      end

      def call_help(*cmds)
        help = Commands::Help.new(@ctx)
        help.call(cmds, nil)
      end

      def call_tip_of_the_day
        tip = TipOfTheDay.call
        if tip
          @ctx.in_frame("Tip of the Day") do
            @ctx.puts(@ctx.message("{{*}} " + tip))
          end
        end
      end
    end

    def initialize(ctx = nil)
      super()
      @ctx = ctx || ShopifyCli::Context.new
      self.options = Options.new
    end
  end
end
