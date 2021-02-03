# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class RustProjectCreator
        include SmartProperties
        property! :ctx, accepts: ShopifyCli::Context
        property! :extension_point, accepts: Domain::ExtensionPoint
        property! :script_name, accepts: String
        property! :path_to_project, accepts: String

        ORIGIN_BRANCH = 'main'
        SAMPLE_PATH = 'default'

        def setup_dependencies
          git_init
          setup_remote
          setup_sparse_checkout
        end

        def bootstrap
          pull
          clean
        end

        private

        def git_init
          out, status = ctx.capture2e("git init")
          raise Domain::Errors::ServiceFailureError, out unless status.success?
        end

        def setup_remote
          repo = extension_point.sdks.rust.package
          out, status = ctx.capture2e("git remote add -f origin #{repo}")
          raise Domain::Errors::ServiceFailureError, out unless status.success?
        end

        def setup_sparse_checkout
          type = extension_point.type
          out, status = ctx.capture2e("git config core.sparsecheckout true")
          raise Domain::Errors::ServiceFailureError, out unless status.success?
          out, status = ctx.capture2e("echo #{type}/#{SAMPLE_PATH} >> .git/info/sparse-checkout")
          raise Domain::Errors::ServiceFailureError, out unless status.success?
        end

        def pull
          out, status = ctx.capture2e("git pull origin #{ORIGIN_BRANCH}")
          raise Domain::Errors::ServiceFailureError, out unless status.success?
        end

        def clean
          type = extension_point.type
          ctx.rm_rf(".git")
          source = File.join(path_to_project, File.join(type, SAMPLE_PATH))
          FileUtils.copy_entry(source, path_to_project)
          ctx.rm_rf(type)
        end
      end
    end
  end
end
