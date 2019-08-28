# frozen_string_literal: true
require 'shopify_cli'

module ShopifyCli
  class Command < CLI::Kit::BaseCommand
    attr_writer :ctx
    attr_accessor :options

    class << self
      attr_writer :ctx

      def call(args, command_name)
        cmd = new
        cmd.ctx = @ctx
        cmd.options = Options.new
        cmd.options.parse(@_options, args)
        cmd.call(args, command_name)
      end

      def options(&block)
        @_options = block
      end

      def prerequisite_task(*tasks)
        tasks.each do |task|
          prerequisite_tasks[task] = ShopifyCli::Tasks::Registry[task]
        end
      end

      def prerequisite_tasks
        @prerequisite_tasks ||= {}
      end
    end

    def initialize(ctx = nil)
      @ctx = ctx || ShopifyCli::Context.new
    end
  end
end
