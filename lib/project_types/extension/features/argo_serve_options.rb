module Extension
  module Features
    class ArgoServeOptions
      include SmartProperties

      property! :argo_runtime, accepts: Features::ArgoRuntime
      property! :context, accepts: ShopifyCli::Context
      property  :port, accepts: Integer, default: 39351
      property  :public_url, accepts: String, default: ""
      property! :required_fields, accepts: Array, default: -> { [] }
      property! :renderer_package, accepts: Models::NpmPackage

      YARN_SERVE_COMMAND = %w(server)
      NPM_SERVE_COMMAND = %w(run-script server)

      def yarn_serve_command
        YARN_SERVE_COMMAND + options
      end

      def npm_serve_command
        NPM_SERVE_COMMAND  + ["--"] + options
      end

      def argo_admin_beta?
        ShopifyCli::Shopifolk.check && ShopifyCli::Feature.enabled?(:argo_admin_beta)
      end

      private

      def options
        project = ExtensionProject.current

        @serve_options ||= [].tap do |options|
          options << "--port=#{port}" if argo_runtime.accepts_port?
          options << "--shop=#{project.env.shop}" if required_fields.include?(:shop) && argo_admin_beta?
          options << "--apiKey=#{project.env.api_key}" if required_fields.include?(:api_key) && argo_admin_beta?
          options << "--argoVersion=#{renderer_package.version}" if argo_runtime.accepts_argo_version?
          options << "--uuid=#{project.registration_uuid}" if argo_runtime.accepts_uuid?
          options << "--publicUrl=#{public_url}" if argo_runtime.accepts_tunnel_url?
        end
      end
    end
  end
end
