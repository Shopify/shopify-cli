# frozen_string_literal: true
module Extension
  module Features
    module Argo
      class Admin < Base
        GIT_TEMPLATE = 'https://github.com/Shopify/argo-admin-template.git'
        RENDERER_PACKAGE = '@shopify/argo-admin'
        private_constant :GIT_TEMPLATE, :RENDERER_PACKAGE

        def git_template
          GIT_TEMPLATE
        end

        def git_branch
          'default-extension-template'
        end

        def renderer_package_name
          RENDERER_PACKAGE
        end
      end
    end
  end
end
