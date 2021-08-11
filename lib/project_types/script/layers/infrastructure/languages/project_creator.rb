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
          # property! :extension_point, accepts: Domain::ExtensionPoint
          property! :script_name, accepts: String
          property! :path_to_project, accepts: String
          property! :branch, accepts: String

          def self.for(input)
            ctx, language, domain, type, repo, script_name, path_to_project, branch = input
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
              # extension_point: extension_point,
              script_name: script_name,
              path_to_project: path_to_project,
              branch: branch
            )
          end

          def self.config_file
            # TODO: This error type may be wrong?
            # http://chrisstump.online/2016/03/23/stop-abusing-notimplementederror/
            raise NotImplementedError
          end

          # the sparse checkout process is common to all script types
          def setup_dependencies
            setup_sparse_checkout
            clean
            update_script_name(self.class.config_file)
          end

          # this should be passed to the ProjectCreator, we shouldn't have to do it manually ourselves
          def sparse_checkout_set_path
            if domain.nil?
              "packages/default/extension-point-as-#{type}/assembly/sample"
            else
              "packages/#{domain}/samples/#{type}"
            end
          end

          private

          def setup_sparse_checkout
            path = sparse_checkout_set_path
            ShopifyCli::Git.sparse_checkout(repo, path, branch, ctx)
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
      end
    end
  end
end
