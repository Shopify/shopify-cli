# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      module Languages
        class TypeScriptProjectCreator < ProjectCreator
          def setup_dependencies
            task_runner = Infrastructure::Languages::TypeScriptTaskRunner.new(ctx)
            task_runner.set_npm_config

            super

            if ctx.file_exist?("yarn.lock")
              ctx.rm("yarn.lock")
            end

            if ctx.file_exist?("package-lock.json")
              ctx.rm("package-lock.json")
            end

            update_package_json_name
          end

          private

          def update_package_json_name
            file_content = ctx.read("package.json")
            hash = file_content_to_hash(file_content)
            hash["name"] = project_name
            ctx.write("package.json", hash_to_file_content(hash))
          end

          def file_content_to_hash(content)
            JSON.parse(content)
          end

          def hash_to_file_content(hash)
            JSON.pretty_generate(hash)
          end
        end
      end
    end
  end
end
