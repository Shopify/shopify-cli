# frozen_string_literal: true
require "shopify_cli"
require "semantic/semantic"

module ShopifyCLI
  class Command < CLI::Kit::BaseCommand
    autoload :SubCommand,     "shopify_cli/command/sub_command"
    autoload :AppSubCommand,  "shopify_cli/command/app_sub_command"
    autoload :ProjectCommand, "shopify_cli/command/project_command"

    VersionRange = Struct.new(:from, :to, keyword_init: true)

    extend Feature::Set

    attr_writer :ctx
    attr_accessor :options

    class << self
      attr_writer :ctx, :task_registry

      def call(args, command_name, *)
        subcommand, resolved_name = subcommand_registry.lookup_command(args.first)
        if subcommand
          subcommand.ctx = @ctx
          subcommand.task_registry = @task_registry

          subcommand.call(args.drop(1), resolved_name, command_name)
        else
          cmd = new(@ctx)
          cmd.options.parse(@_options, args)
          return call_help(command_name) if cmd.options.help
          check_ruby_version
          check_node_version
          run_prerequisites
          cmd.call(args, command_name)
        end
      rescue OptionParser::InvalidOption => error
        arg = error.args.first
        store_name = arg.match(/\A--(?<store_name>.*\.myshopify\.com)\z/)&.[](:store_name)
        if store_name && !arg.match?(/\A--(store|shop)=/)
          # Sometimes it may look like --invalidoption=https://storename.myshopify.com
          store_name = store_name.sub(%r{\A(.*=)?(https?://)?}, "")
          raise ShopifyCLI::Abort,
            @ctx.message("core.errors.option_parser.invalid_option_store_equals", arg, store_name)
        end
        raise ShopifyCLI::Abort, @ctx.message("core.errors.option_parser.invalid_option", arg)
      rescue OptionParser::MissingArgument => error
        arg = error.args.first
        raise ShopifyCLI::Abort, @ctx.message("core.errors.option_parser.missing_argument", arg)
      end

      def options(&block)
        existing_options = @_options
        # We prevent new options calls to override existing blocks by nesting them.
        @_options = ->(parser, flags) {
          existing_options&.call(parser, flags)
          block.call(parser, flags)
        }
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

      def recommend_ruby(from:, to:)
        @compatible_ruby_range = VersionRange.new(
          from: Semantic::Version.new(from),
          to: Semantic::Version.new(to)
        )
      end

      def recommend_default_ruby_range
        recommend_ruby(
          from: Constants::SupportedVersions::Ruby::FROM,
          to: Constants::SupportedVersions::Ruby::TO
        )
      end

      def check_ruby_version
        check_version(
          Environment.ruby_version,
          range: @compatible_ruby_range,
          runtime: "Ruby"
        )
      end

      def recommend_node(from:, to:)
        @compatible_node_range = VersionRange.new(
          from: Semantic::Version.new(from),
          to: Semantic::Version.new(to)
        )
      end

      def recommend_default_node_range
        recommend_node(
          from: Constants::SupportedVersions::Node::FROM,
          to: Constants::SupportedVersions::Node::TO
        )
      end

      def check_node_version
        return unless @compatible_node_range

        check_version(
          Environment.node_version,
          range: @compatible_node_range,
          runtime: "Node"
        )
      end

      def check_version(version, range:, runtime:, context: Context.new)
        return if Environment.test? || Environment.run_as_subprocess?
        return if range.nil?

        version_without_pre_nor_build = Utilities.version_dropping_pre_and_build(version)
        is_higher_than_bottom = version_without_pre_nor_build >= Utilities.version_dropping_pre_and_build(range.from)
        is_lower_than_top = version_without_pre_nor_build < Utilities.version_dropping_pre_and_build(range.to)
        return if is_higher_than_bottom && is_lower_than_top

        context.warn("Your environment #{runtime} version, #{version},"\
          " is outside of the range supported by the CLI,"\
          " #{range.from}..<#{range.to},"\
          " and might cause incompatibility issues.")
      rescue StandardError => error
        ExceptionReporter.report_error_silently(error)
      end

      def prerequisite_task(*tasks_without_args, **tasks_with_args)
        @prerequisite_tasks ||= []
        @prerequisite_tasks += tasks_without_args.map { |t| PrerequisiteTask.new(t) }
        @prerequisite_tasks += tasks_with_args.map { |t, args| PrerequisiteTask.new(t, args) }
      end

      def run_prerequisites
        (@prerequisite_tasks || []).each do |task|
          task_registry[task.name]&.call(@ctx, *task.args)
        end
      end

      def task_registry
        @task_registry || ShopifyCLI::Tasks::Registry
      end

      def call_help(*cmds)
        help = Commands::Help.new(@ctx)
        help.call(cmds, nil)
      end

      class PrerequisiteTask
        attr_reader :name, :args

        def initialize(name, args = [])
          @name = name
          @args = args
        end
      end
    end

    def initialize(ctx = nil)
      super()
      @ctx = ctx || ShopifyCLI::Context.new
      self.options = Options.new
    end
  end
end
