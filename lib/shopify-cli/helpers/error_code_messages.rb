# frozen_string_literal: true
require 'shopify_cli'

module ShopifyCli
  module Helpers
    module ErrorCodeMessages
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
