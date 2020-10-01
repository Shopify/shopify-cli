module Extension
  module ExtensionTestHelpers
    class DummyArgo < Extension::Features::Argo::Base
      GIT_TEMPLATE = "https://something"
      RENDERER_PACKAGE = '@test-renderer-package'
      private_constant :GIT_TEMPLATE, :RENDERER_PACKAGE

      def git_template
        GIT_TEMPLATE
      end

      def renderer_package_name
        RENDERER_PACKAGE
      end
    end
  end
end
