# frozen_string_literal: true
require 'shopify_cli'

module ShopifyCli
  class Command < CLI::Kit::BaseCommand
    attr_writer :ctx
    attr_accessor :options

    class << self
      attr_writer :ctx

      def available?
        return true if available.empty?
        return true if !Project.directory(Dir.pwd) && available.include?(:top_level)
        return false unless Project.directory(Dir.pwd)
        available.include?(Project.current.config['project_type'].to_sym)
      end

      def available_in(identifier)
        available << identifier
      end

      def app_type?
        Project.directory(Dir.pwd) && app_type_lookup[self]
      end

      def app_type(identifier, const, path = nil)
        autoload(const, "shopify-cli/commands/#{path}") if path
        app_type_lookup[self] ||= {}
        app_type_lookup[self][identifier] = const_get(const)
      end

      def app_type_lookup
        @app_type_lookup ||= {}
      end

      def call(args, command_name)
        subcommand, resolved_name = subcommand_registry.lookup_command(args.first)
        if subcommand
          subcommand.ctx = @ctx
          unless subcommand.available?
            CLI::UI::Frame.open("Command not available", color: :red, timing: false) do
              $stderr.puts(CLI::UI.fmt("{{command:#{@tool_name} #{command_name} #{resolved_name}}} not available here"))
            end
            raise CLI::Kit::AbortSilent
          end
          subcommand.call(args, resolved_name)
        else
          cmd = new
          cmd.ctx = @ctx
          cmd.options = Options.new
          cmd.options.parse(@_options, args)
          return call_help(command_name) if cmd.options.help
          cmd.call(args, command_name)
        end
      end

      def options(&block)
        @_options = block
      end

      def subcommand(const, cmd, path = nil)
        autoload(const, path) if path
        subcommand_registry.add(->() { const_get(const) }, cmd)
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

      def call_help(name)
        help = Commands::Help.new(@ctx)
        help.call([name], nil)
      end

      private

      def available
        @available || @available = []
      end
    end

    def initialize(ctx = nil)
      @ctx = ctx || ShopifyCli::Context.new
    end
  end
end
