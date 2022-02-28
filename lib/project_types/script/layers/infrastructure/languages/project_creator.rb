# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      module Languages
        class ProjectCreator
          include SmartProperties
          property! :ctx, accepts: ShopifyCLI::Context
          property! :type, accepts: String
          property! :project_name, accepts: String
          property! :path_to_project, accepts: String
          property! :sparse_checkout_repo, accepts: String
          property! :sparse_checkout_branch, accepts: String
          property! :sparse_checkout_set_path, accepts: String

          def self.for(
            ctx:,
            language:,
            type:,
            project_name:,
            path_to_project:,
            sparse_checkout_repo:,
            sparse_checkout_branch:,
            sparse_checkout_set_path:
          )

            project_creators = {
              "assemblyscript" => AssemblyScriptProjectCreator,
              "typescript" => TypeScriptProjectCreator,
              "wasm" => WasmProjectCreator,
            }

            raise Errors::ProjectCreatorNotFoundError unless project_creators[language]
            project_creators[language].new(
              ctx: ctx,
              type: type,
              project_name: project_name,
              path_to_project: path_to_project,
              sparse_checkout_repo: sparse_checkout_repo,
              sparse_checkout_branch: sparse_checkout_branch,
              sparse_checkout_set_path: sparse_checkout_set_path
            )
          end

          # the sparse checkout process is common to all script types
          def setup_dependencies
            setup_sparse_checkout
            clean
          end

          private

          def setup_sparse_checkout
            ShopifyCLI::Git.sparse_checkout(
              sparse_checkout_repo,
              sparse_checkout_set_path,
              sparse_checkout_branch,
              ctx
            )
          end

          def clean
            source = File.join(path_to_project, sparse_checkout_set_path, ".")
            FileUtils.cp_r(source, path_to_project)
            ctx.rm_rf(sparse_checkout_set_path.split("/")[0])
            ctx.rm_rf(".git")
          end

          def command_runner
            @command_runner ||= CommandRunner.new(ctx: ctx)
          end
        end
      end
    end
  end
end
