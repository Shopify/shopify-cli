# typed: ignore
module Extension
  module ExtensionTestHelpers
    class DummyArgo < Extension::Features::Argo
      GIT_TEMPLATE = "https://something"
      RENDERER_PACKAGE = "@shopify/admin-ui-extensions"
      private_constant :GIT_TEMPLATE, :RENDERER_PACKAGE

      property :fake_renderer_package, accepts: Models::NpmPackage

      def git_template
        GIT_TEMPLATE
      end

      def renderer_package_name
        RENDERER_PACKAGE
      end

      def renderer_version=(renderer_version)
        self.fake_renderer_package = Models::NpmPackage.new(
          name: renderer_package_name,
          version: renderer_version
        )
      end

      def renderer_package(context)
        fake_renderer_package || super(context)
      end
    end
  end
end
