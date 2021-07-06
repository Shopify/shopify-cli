module Extension
  module Features
    module Runtimes
      class AdminRuntime < ArgoRuntime
        CLI_PACKAGE_NAME ||= "@shopify/admin-ui-extensions-run"

        AVAILABLE_FLAGS ||= [
          :api_key,
          :name,
          :port,
          :public_url,
          :renderer_version,
          :shop,
          :uuid,
        ]

        def cli_package
          CLI_PACKAGE_NAME
        end

        def available_flags
          AVAILABLE_FLAGS
        end
      end
    end
  end
end
