# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class ProjectCreator
        PROJECT_CREATORS = {
          "ts" => Infrastructure::AssemblyScriptProjectCreator,
        }

        def self.for(ctx, language, extension_point, script_name)
          raise Errors::ProjectCreatorNotFoundError unless PROJECT_CREATORS[language]
          PROJECT_CREATORS[language].new(ctx, extension_point, script_name)
        end
      end
    end
  end
end
