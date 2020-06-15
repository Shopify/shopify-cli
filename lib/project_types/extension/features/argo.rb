# frozen_string_literal: true
require 'base64'

module Extension
  module Features
    class Argo
      include SmartProperties

      GIT_ADMIN_TEMPLATE = 'https://github.com/Shopify/shopify-app-extension-template.git'.freeze
      GIT_CHECKOUT_TEMPLATE = 'https://github.com/Shopify/argo-checkout-template.git'.freeze
      SCRIPT_PATH = %w(build main.js).freeze

      class << self
        def admin
          @admin ||= Argo.new(setup: ArgoSetup.new(git_template: GIT_ADMIN_TEMPLATE))
        end

        def checkout
          @checkout ||= Argo.new(
            setup: ArgoSetup.new(
              git_template: GIT_CHECKOUT_TEMPLATE,
              dependency_checks: [ArgoDependencies.node_installed(min_major: 10, min_minor: 13)]
            )
          )
        end
      end

      property! :setup, accepts: Features::ArgoSetup

      def create(directory_name, identifier, context)
        setup.call(directory_name, identifier, context)
      end

      def config(context)
        filepath = File.join(context.root, SCRIPT_PATH)
        context.abort(context.message('features.argo.missing_file_error')) unless File.exists?(filepath)

        begin
          {
            serialized_script: Base64.strict_encode64(File.open(filepath).read.chomp)
          }
        rescue Exception
          context.abort(context.message('features.argo.script_prepare_error'))
        end
      end
    end
  end
end
