# frozen_string_literal: true
require 'bundler/setup'
require "pry"

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
          property! :project_name, accepts: String
          property! :path_to_project, accepts: String
          property! :branch, accepts: String
          property! :sparse_checkout_set_path, accepts: String

          def self.for(
            ctx:, language:, domain:, type:, repo:,
            project_name:, path_to_project:, branch:, sparse_checkout_set_path:
          )

            project_creators = {
              "assemblyscript" => AssemblyScriptProjectCreator,
              "rust" => RustProjectCreator,
            }

            raise Errors::ProjectCreatorNotFoundError unless project_creators[language]
            project_creators[language].new(
              ctx: ctx,
              domain: domain,
              type: type,
              repo: repo,
              project_name: project_name,
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
            update_project_name(File.join(path_to_project, self.class.config_file))
          end

          private

          def setup_sparse_checkout
            ShopifyCli::Git.sparse_checkout(repo, sparse_checkout_set_path, branch, ctx)
          end

          def clean
            # When I changed the next 2 lines of code to use cp_r, I no longer need to add the weird
            # trailing . on sparse_checkout_set_path in unit test.  Oh well, this just means that we can't
            # use copy_entry.
            source = File.join(path_to_project, sparse_checkout_set_path, ".")
            FileUtils.cp_r(source, path_to_project)
            # ctx.rm_rf("packages") # TODO: - needs to be language agnostic
            # I think this fixes it, and doesn't need to be language agnostic
            ctx.rm_rf(sparse_checkout_set_path.split('/')[0])
            ctx.rm_rf(".git")
          end

          def update_project_name(config_file)
            upstream_name = "#{type.gsub("_", "-")}-default"
            contents = File.read(config_file)
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
