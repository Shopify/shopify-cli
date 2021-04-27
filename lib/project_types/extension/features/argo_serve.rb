module Extension
  module Features
    class ArgoServe
      include SmartProperties

      property! :specification_handler, accepts: Extension::Models::SpecificationHandlers::Default
      property! :context, accepts: ShopifyCli::Context

      YARN_SERVE_COMMAND = %w(server)
      NPM_SERVE_COMMAND = %w(run-script server)

      def call
        validate_env!

        CLI::UI::Frame.open(context.message("serve.frame_title")) do
          success = ShopifyCli::JsSystem.call(context, yarn: yarn_serve_command, npm: npm_serve_command)
          context.abort(context.message("serve.serve_failure_message")) unless success
        end
      end

      private

      def specification
        specification_handler.specification
      end

      def validate_env!
        ExtensionProject.reload

        ShopifyCli::Shopifolk.check && ShopifyCli::Feature.enabled?(:argo_admin_beta)

        required_fields = specification.features.argo.required_fields

        return if required_fields.none?

        ShopifyCli::Tasks::EnsureEnv.call(context, required: required_fields)
        ShopifyCli::Tasks::EnsureDevStore.call(context) if required_fields.include?(:shop)

        project = ExtensionProject.current

        return if required_fields.all? do |field|
          value = project.env.public_send(field)
          value && !value.strip.empty?
        end

        context.abort(context.message("serve.serve_missing_information"))
      end

      def yarn_serve_command
        YARN_SERVE_COMMAND + serve_options(specification.features.argo.required_fields)
      end

      def npm_serve_command
        NPM_SERVE_COMMAND + ["--"] + serve_options(specification.features.argo.required_fields)
      end

      def serve_options(required_fields)
        renderer_package = specification_handler.renderer_package(context)
        project = ExtensionProject.current
        @serve_options ||= [].tap do |options|
          options << "--shop=#{project.env.shop}" if required_fields.include?(:shop)
          options << "--apiKey=#{project.env.api_key}" if required_fields.include?(:api_key)
          options << "--argoVersion=#{renderer_package.version}" if renderer_package.admin?
          options << "--uuid=#{project.registration_uuid}" if renderer_package.supports_uuid_flag?
        end
      end
    end
  end
end
