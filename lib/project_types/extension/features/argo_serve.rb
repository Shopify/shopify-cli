module Extension
  module Features
    class ArgoServe
      include SmartProperties

      YARN_SERVE_COMMAND = %w(server)
      NPM_SERVE_COMMAND = %w(run-script server)

      property! :specification_handler, accepts: Extension::Models::SpecificationHandlers::Default
      property :argo_runtime, accepts: -> (runtime) { runtime.class < Features::Runtimes::Base }
      property! :context, accepts: ShopifyCLI::Context
      property! :port, accepts: Integer
      property  :tunnel_url, accepts: String, default: nil
      property! :js_system, accepts: ->(jss) { jss.respond_to?(:call) }, default: ShopifyCLI::JsSystem
      property :resource_url, accepts: String, default: nil

      def call
        validate_env!

        CLI::UI::Frame.open(context.message("serve.frame_title")) do
          next if start_server
          context.abort(context.message("serve.serve_failure_message"))
        end
      end

      def resource_url
        super || ExtensionProject.current(force_reload: true).resource_url
      end

      private

      def start_server
        return new_serve_flow if supports_development_server?
        js_system.call(context, yarn: yarn_serve_command, npm: npm_serve_command)
      end

      def specification
        specification_handler.specification
      end

      def renderer_package
        specification_handler.renderer_package(context)
      end

      def required_fields
        specification.features.argo.required_fields
      end

      def yarn_serve_command
        YARN_SERVE_COMMAND + options
      end

      def npm_serve_command
        NPM_SERVE_COMMAND  + ["--"] + options
      end

      def validate_env!
        ExtensionProject.reload

        return if required_fields.none?

        ShopifyCLI::Tasks::EnsureEnv.call(context, required: required_fields)
        ShopifyCLI::Tasks::EnsureDevStore.call(context) if required_fields.include?(:shop)

        project = ExtensionProject.current
        if resource_url_required?
          Tasks::EnsureResourceUrl.call(context: context, specification_handler: specification_handler)
        end

        return if required_fields.all? do |field|
          value = project.env.public_send(field)
          value && !value.strip.empty?
        end

        context.abort(context.message("serve.serve_missing_information"))
      end

      def resource_url_required?
        specification_handler.supplies_resource_url? && resource_url.nil?
      end

      def options
        project = ExtensionProject.current

        @serve_options ||= [].tap do |options|
          options << "--port=#{port}" if argo_runtime.supports?(:port)
          options << "--store=#{project.env.shop}" if argo_runtime.supports?(:shop)
          options << "--apiKey=#{project.env.api_key}" if argo_runtime.supports?(:api_key)
          options << "--rendererVersion=#{renderer_package.version}" if argo_runtime.supports?(:renderer_version)
          options << "--uuid=#{project.registration_uuid}" if argo_runtime.supports?(:uuid)
          options << "--publicUrl=#{tunnel_url}" if !tunnel_url.nil? && argo_runtime.supports?(:public_url)
          options << "--name=#{project.title}" if argo_runtime.supports?(:name)
          options << "--resourceUrl=#{resource_url}" if !resource_url.nil? && argo_runtime.supports?(:resource_url)
        end
      end

      def new_serve_flow
        Tasks::ExecuteCommands.serve(
          type: specification_handler.specification.identifier,
          context: context,
          config_file_path: specification_handler.server_config_path,
          port: port,
          resource_url: resource_url,
          tunnel_url: tunnel_url
        ).unwrap do |error|
          raise error unless error.nil?
        end
      end

      def supports_development_server?
        Models::DevelopmentServerRequirements.supported?(specification_handler.specification.identifier)
      end
    end
  end
end
