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
          property! :sparse_checkout_details, accepts: SparseCheckoutDetails

          def self.for(
            ctx:,
            language:,
            type:,
            project_name:,
            path_to_project:,
            sparse_checkout_details:
          )

            project_creators = {
              "typescript" => TypeScriptProjectCreator,
              "wasm" => WasmProjectCreator,
            }

            raise Errors::ProjectCreatorNotFoundError unless project_creators[language]
            project_creators[language].new(
              ctx: ctx,
              type: type,
              project_name: project_name,
              path_to_project: path_to_project,
              sparse_checkout_details: sparse_checkout_details,
            )
          end

          # the sparse checkout process is common to all script types
          def setup_dependencies
            sparse_checkout_details.setup(ctx)
            clean
          end

          private

          def clean
            source = File.join(path_to_project, sparse_checkout_details.path, ".")
            FileUtils.cp_r(source, path_to_project)
            ctx.rm_rf(sparse_checkout_details.path.split("/")[0])
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
