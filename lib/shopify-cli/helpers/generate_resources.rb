# frozen_string_literal: true
require 'shopify_cli'

module ShopifyCli
  module Helpers
    module GenerateResources
      def run_generate(script, name, ctx)
        stat = ctx.system(script)
        unless stat.success?
          raise(ShopifyCli::Abort, response(stat.exitstatus, name))
        end
      end

      def response(code, name)
        case code
        when 1
          "Error generating #{name}"
        when 2
          "#{name} already exists!"
        else
          'Error'
        end
      end
    end
  end
end
