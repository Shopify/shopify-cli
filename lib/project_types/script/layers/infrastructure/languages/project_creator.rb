# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      module Languages
        class ProjectCreator
          include SmartProperties
          property! :ctx, accepts: ShopifyCli::Context
          property! :domain, accepts: String
          property! :type, accepts: String
          property! :repo, accepts: String
          property! :script_name, accepts: String
          property! :path_to_project, accepts: String
          property! :branch, accepts: String
          property! :sparse_checkout_set_path, accepts: String

          def self.for(
            ctx:, language:, domain:, type:, repo:,
            script_name:, path_to_project:, branch:, sparse_checkout_set_path:
          )

            project_creators = {
              "generic" => GenericProjectCreator,
              "assemblyscript" => AssemblyScriptProjectCreator,
              "rust" => RustProjectCreator,
            }

            raise Errors::ProjectCreatorNotFoundError unless project_creators[language]
            project_creators[language].new(
              ctx: ctx,
              domain: domain,
              type: type,
              repo: repo,
              script_name: script_name,
              path_to_project: path_to_project,
              branch: branch,
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
            update_script_name(self.class.config_file)
          end

          private

          def setup_sparse_checkout
            ShopifyCli::Git.sparse_checkout(repo, sparse_checkout_set_path, branch, ctx)
          end

          def update_script_name(config_file)
            upstream_name = "#{type.gsub("_", "-")}-default"
            contents = File.read(config_file)
            new_contents = contents.gsub(upstream_name, script_name)
            File.write(config_file, new_contents)
          end

          def clean
            source = File.join(path_to_project, sparse_checkout_set_path)
            FileUtils.copy_entry(source, path_to_project)
            ctx.rm_rf("packages") # TODO: - needs to be language agnostic
            ctx.rm_rf(".git")
          end

          def command_runner
            @command_runner ||= CommandRunner.new(ctx: ctx)
          end
        end

        class GenericProjectCreator < ProjectCreator
          def self.config_file
            "package.json"
          end
        end
      end
    end
  end
end
