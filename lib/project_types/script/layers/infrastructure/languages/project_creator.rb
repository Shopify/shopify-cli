# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      module Languages
        class ProjectCreator
          PROJECT_CREATORS = {
            "assemblyscript" => AssemblyScriptProjectCreator,
            "rust" => RustProjectCreator,
          }

          def self.for(ctx, language, extension_point, script_name, path_to_project)
            raise Errors::ProjectCreatorNotFoundError unless PROJECT_CREATORS[language]
            PROJECT_CREATORS[language].new(
              ctx: ctx,
              extension_point: extension_point,
              script_name: script_name,
              path_to_project: path_to_project
            )
          end
        end
      end
    end
  end
end
