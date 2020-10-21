# frozen_string_literal: true
module Extension
  module Features
    module Argo
      class Checkout < Base
        GIT_TEMPLATE = 'https://github.com/Shopify/argo-checkout-template.git'
        RENDERER_PACKAGE = '@shopify/argo-checkout'
        private_constant :GIT_TEMPLATE, :RENDERER_PACKAGE

        def git_template
          GIT_TEMPLATE
        end

        def renderer_package_name
          RENDERER_PACKAGE
        end
      end
    end
  end
end
