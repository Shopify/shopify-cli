module Extension
  module Features
    class ArgoServeOptions
      include SmartProperties
      property! :context, accepts: ShopifyCli::Context
      property! :renderer_package, accepts: Features::ArgoRendererPackage
      property! :required_fields, accepts: Array, default: []
      property :public_url, default: ""

      YARN_SERVE_COMMAND = %w(server)
      NPM_SERVE_COMMAND = %w(run-script server)

      def yarn_serve_command
        YARN_SERVE_COMMAND + options
      end

      def npm_serve_command
        NPM_SERVE_COMMAND  + ["--"] + options
      end

      def public_url_available?
        !public_url.empty?
      end

      private

      def options
        project = ExtensionProject.current
        @serve_options ||= [].tap do |options|
          options << "--shop=#{project.env.shop}" if required_fields.include?(:shop)
          options << "--apiKey=#{project.env.api_key}" if required_fields.include?(:api_key)
          options << "--argoVersion=#{renderer_package.version}" if renderer_package.admin?
          options << "--uuid=#{project.registration_uuid}" if renderer_package.supports_uuid_flag?
          options << "--publicUrl=#{public_url}" if public_url_available?
        end
      end
    end
  end
end
