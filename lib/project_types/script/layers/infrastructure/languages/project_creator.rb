# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      module Languages
        class ProjectCreator
          include SmartProperties
          property! :ctx, accepts: ShopifyCli::Context
          property! :extension_point, accepts: Domain::ExtensionPoint
          property! :script_name, accepts: String
          property! :path_to_project, accepts: String
          property! :branch, accepts: String

          def self.for(ctx, language, extension_point, script_name, path_to_project, branch)

            project_creators = {
              "assemblyscript" => AssemblyScriptProjectCreator,
              "rust" => RustProjectCreator,
            }

            raise Errors::ProjectCreatorNotFoundError unless project_creators[language]
            project_creators[language].new(
              ctx: ctx,
              extension_point: extension_point,
              script_name: script_name,
              path_to_project: path_to_project,
              branch: branch
            )
          end

          # the sparse checkout process is common to all script types
          def setup_dependencies
            
            setup_sparse_checkout

            @config_files = {
              "assemblyscript" => "package.json",
              "rust" => "cargo.toml",
            }

            clean
            set_script_name(@config_files["assemblyscript"])
            
          end

          def setup_sparse_checkout
            repo = extension_point.sdks.assemblyscript.repo
            path = sparse_checkout_set_path
            ShopifyCli::Git.sparse_checkout(repo, path, branch, ctx)
          end

          # this should be passed to the ProjectCreator, we shouldn't have to do it manually ourselves
          def sparse_checkout_set_path
            type = extension_point.dasherize_type
            domain = extension_point.domain

            if domain.nil?
              "packages/default/extension-point-as-#{type}/assembly/sample"
            else
              "packages/#{domain}/samples/#{type}"
            end
          end

          def set_script_name(config_file)

            upstream_name = "#{extension_point.type.gsub("_", "-")}-default"
            contents = File.read(config_file)
            new_contents = contents.sub(upstream_name, script_name)
            File.write(config_file, new_contents)
          end

          def clean
            source = File.join(path_to_project, sparse_checkout_set_path)
            FileUtils.copy_entry(source, path_to_project)
            ctx.rm_rf("packages") #TODO - needs to be language agnostic
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
