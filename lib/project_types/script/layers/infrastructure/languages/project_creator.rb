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
              "rust" => RustProjectCreator,
              "typescript" => TypeScriptProjectCreator,
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

          def self.config_file
            raise NotImplementedError
          end

          # the sparse checkout process is common to all script types
          def setup_dependencies
            setup_sparse_checkout
            clean
            update_project_name(File.join(path_to_project, self.class.config_file))
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

          def update_project_name(config_file)
            raise Errors::ProjectConfigNotFoundError unless File.exist?(config_file)
            upstream_name = "#{type.gsub("_", "-")}-default"
            contents = File.read(config_file)

            raise Errors::InvalidProjectConfigError unless contents.include?(upstream_name)
            new_contents = contents.gsub(upstream_name, project_name)
            File.write(config_file, new_contents)
          end

          def command_runner
            @command_runner ||= CommandRunner.new(ctx: ctx)
          end
        end
      end
    end
  end
end
