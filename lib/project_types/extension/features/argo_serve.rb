module Extension
  module Features
    class ArgoServe
      include SmartProperties

      YARN_SERVE_COMMAND = %w(server)
      NPM_SERVE_COMMAND = %w(run-script server)

      property! :specification_handler, accepts: Extension::Models::SpecificationHandlers::Default
      property :argo_runtime, accepts: -> (runtime) { runtime.class < Features::Runtimes::Base }
      property! :context, accepts: ShopifyCLI::Context
      property! :port, accepts: Integer, default: 39351
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
        ensure_resource_resource_url! if specification_handler.supplies_resource_url?

        return if required_fields.all? do |field|
          value = project.env.public_send(field)
          value && !value.strip.empty?
        end

        context.abort(context.message("serve.serve_missing_information"))
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

      def ensure_resource_resource_url!
        project = ExtensionProject.current(force_reload: true)

        ShopifyCLI::Result
          .wrap(project.resource_url)
          .rescue { specification_handler.build_resource_url(shop: project.env.shop, context: context) }
          .then(&method(:persist_resource_url))
          .unwrap do |nil_or_exception|
            case nil_or_exception
            when nil
              context.warn(context.message("warnings.resource_url_auto_generation_failed", project.env.shop))
            else
              context.abort(nil_or_exception)
            end
          end
      end

      def persist_resource_url(resource_url)
        ExtensionProject.update_env_file(context: context, resource_url: resource_url)
        resource_url
      end

      def new_serve_flow
        Tasks::RunExtensionCommand.new(
          type: specification_handler.specification.identifier,
          command: "serve",
          context: context,
          port: port,
        ).call
      end

      def supports_development_server?
        Models::DevelopmentServerRequirements.supported?(specification_handler.specification.identifier)
      end
    end
  end
end
