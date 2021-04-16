module Extension
  module Features
    class ArgoServe
      include SmartProperties

      property! :specification_handler, accepts: Extension::Models::SpecificationHandlers::Default
      property! :context, accepts: ShopifyCli::Context
      property :flags, accepts: Hash, default: {}

      DEFAULT_PORT = 39351

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

      def tunnel_required?
        !!flags[:tunnel]
      end

      def tunnel
        context.abort("No ports available") if port.nil?
        @tunnel ||= ShopifyCli::Tunnel.start(context, port: port)
      end

      def port
        Tasks::ChooseNextAvailablePort.new(from: DEFAULT_PORT).call
          .unwrap { nil }
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

      def renderer_package
        specification_handler.renderer_package(context)
      end

      def required_fields
        specification.features.argo.required_fields
      end

      def public_url
        return tunnel if tunnel_required?
        ""
      end

      def serve_options
        @options ||= Features::ArgoServeOptions.new(context: context, renderer_package: renderer_package,
          required_fields: required_fields, public_url: public_url)
      end

      def yarn_serve_command
        serve_options.yarn_serve_command
      end

      def npm_serve_command
        serve_options.npm_serve_command
      end
    end
  end
end
