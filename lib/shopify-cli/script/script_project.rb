# frozen_string_literal: true
require 'shopify_cli'

module ShopifyCli
  module ScriptModule
    class ScriptProject < ShopifyCli::Project
      attr_reader :extension_point_type, :script_name, :language

      def initialize(dir)
        super(dir)
        @extension_point_type = lookup_config('extension_point_type')
        @script_name = lookup_config('script_name')
        @language = 'ts'
      end

      private

      def lookup_config(key)
        raise InvalidScriptProjectContextError, key unless config.key?(key)
        config[key]
      end

      class << self
        def create(dir)
          FileUtils.mkdir_p(dir)
          Dir.chdir(dir)
        end
      end
    end
  end
end
