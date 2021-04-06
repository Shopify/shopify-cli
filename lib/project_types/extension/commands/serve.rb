# frozen_string_literal: true

module Extension
  class Command
    class Serve < ExtensionCommand
      YARN_SERVE_COMMAND = %w(server)
      NPM_SERVE_COMMAND = %w(run-script server)

      def call(_args, _command_name)
        if argo_admin?
          ShopifyCli::Tasks::EnsureEnv.call(@ctx, required: [:api_key, :secret, :shop])
          ShopifyCli::Tasks::EnsureDevStore.call(@ctx)
          validate_env
        end

        CLI::UI::Frame.open(@ctx.message("serve.frame_title")) do
          yarn_serve_command = YARN_SERVE_COMMAND
          npm_serve_command = NPM_SERVE_COMMAND
          if argo_admin?
            serve_args = %W(--shop=#{project.env.shop} --apiKey=#{project.env.api_key})
            yarn_serve_command += serve_args
            npm_serve_command += %w(--) + serve_args
          end
          success = ShopifyCli::JsSystem.call(@ctx, yarn: yarn_serve_command, npm: npm_serve_command)
          @ctx.abort(@ctx.message("serve.serve_failure_message")) unless success
        end
      end

      def self.help
        ShopifyCli::Context.new.message("serve.help", ShopifyCli::TOOL_NAME)
      end

      private

      def argo_admin?
        ShopifyCli::Shopifolk.check &&
          ShopifyCli::Feature.enabled?(:argo_admin_beta) &&
          specification_handler.specification.features&.argo&.surface == "admin"
      end

      def validate_env
        ExtensionProject.reload
        @ctx.abort(@ctx.message("serve.serve_missing_information")) if
          project.env.shop.nil? || project.env.api_key.nil? ||
          project.env.shop.strip.empty? || project.env.api_key.strip.empty?
      end
    end
  end
end
