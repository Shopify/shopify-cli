module Extension
  module Features
    class ArgoCliCompatibility
      include SmartProperties

      VERSION_0_11_0 = "0.11.0"
      VERSION_0_9_3 = "0.9.3"

      property! :renderer_package, accepts: Features::ArgoRendererPackage
      property! :installed_cli_package, accepts: Models::NpmPackage

      def accepts_port?
        renderer_package.admin? && supported_since?(VERSION_0_11_0)
      end

      def accepts_tunnel_url?
        renderer_package.admin? && supported_since?(VERSION_0_11_0)
      end

      def accepts_uuid?
        renderer_package.admin? && supported_since?(VERSION_0_11_0)
      end

      def accepts_argo_version?
        renderer_package.admin? && supported_since?(VERSION_0_9_3)
      end

      private

      def supported_since?(version)
        installed_cli_package >= Models::NpmPackage.new(name: installed_cli_package.name, version: version)
      end
    end
  end
end
