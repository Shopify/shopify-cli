# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      module Languages
        class AssemblyScriptProjectCreator < ProjectCreator
          def setup_dependencies
            task_runner = Infrastructure::Languages::AssemblyScriptTaskRunner.new(ctx)
            task_runner.set_npm_config
            super

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
