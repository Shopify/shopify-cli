# frozen_string_literal: true
require 'shopify_cli'

module ShopifyCli
  class Command < CLI::Kit::BaseCommand
    class << self
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
      self.class.prerequisite_tasks.each do |_, task|
        task.call(ctx)
      end
    end
  end
end
