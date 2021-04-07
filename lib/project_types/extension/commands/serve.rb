# frozen_string_literal: true

module Extension
  module Commands
    class Serve < ExtensionCommand
      YARN_SERVE_COMMAND = %w(server)
      NPM_SERVE_COMMAND = %w(run-script server)

      def call(_args, _command_name)
        validate_env!

        CLI::UI::Frame.open(@ctx.message("serve.frame_title")) do
          success = ShopifyCli::JsSystem.call(@ctx, yarn: yarn_serve_command, npm: npm_serve_command)
          @ctx.abort(@ctx.message("serve.serve_failure_message")) unless success
        end
      end

      def self.help
        <<~HELP
          Serve your extension in a local simulator for development.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} serve}}
        HELP
      end

      private

      def validate_env!
        return unless ShopifyCli::Shopifolk.check &&
          specification.feature?(:argo) &&
          specification.required_beta_flags.all? { |beta| ShopifyCli::Feature.enabled?(beta) }

        required_fields = [].tap do |fields|
          fields << :api_key if specification.features.argo.serve_requires_api_key?
          fields << :shop if specification.features.argo.serve_requires_shop?
        end

        return if required_fields.none?

        ShopifyCli::Tasks::EnsureEnv.call(@ctx, required: required_fields)
        ShopifyCli::Tasks::EnsureDevStore.call(@ctx) if required_fields.include?(:shop)
        ExtensionProject.reload

        return if required_fields.all? do |field|
          value = project.env.public_send(field)
          value && !value.strip.empty?
        end

        @ctx.abort(@ctx.message("serve.serve_missing_information"))
      end

      def yarn_serve_command
        YARN_SERVE_COMMAND + serve_options
      end

      def npm_serve_command
        NPM_SERVE_COMMAND + ["--"] + serve_options
      end

      def serve_options
        requires_version = specification.features.argo.serve_requires_version?
        @serve_options ||= [].tap do |options|
          options << "--shop=#{project.env.shop}" if specification.features.argo.serve_requires_shop?
          options << "--apiKey=#{project.env.api_key}" if specification.features.argo.serve_requires_api_key?
          options << "--argoVersion=#{specification_handler.argo_version}" if requires_version
        end
      end
    end
  end
end
