# frozen_string_literal: true
require "date"

module ShopifyCLI
  module Migrator
    class Migration
      attr_reader :name, :path, :date

      def initialize(name:, path:, date:)
        @name = name
        @path = path
        @date = date
      end

      def run
        require(path)
        ShopifyCLI::Migrator::Migrations.const_get(class_name).run
      rescue StandardError
        # Continue
      end

      def class_name
        name.split("_").collect(&:capitalize).join
      end
    end
  end
end
