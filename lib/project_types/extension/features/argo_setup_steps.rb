# frozen_string_literal: true

module Extension
  module Features
    module ArgoSetupSteps
      YARN_INITIALIZE_COMMAND = %w(generate).freeze
      NPM_INITIALIZE_COMMAND = %w(run generate --).freeze
      INITIALIZE_TYPE_PARAMETER = "--type=%s"

      def self.check_dependencies(dependency_checks)
        ArgoSetupStep.always_successful do |context, _identifier, _directory_name, _js_system|
          dependency_checks.each do |dependency_check|
            dependency_check.call(context)
          end
        end
      end

      def self.clone_template(git_template)
        ArgoSetupStep.default do |context, _identifier, directory_name, _js_system|
          ShopifyCLI::Git.clone(git_template, directory_name, ctx: context)
          context.root = File.join(context.root, directory_name)
        rescue StandardError
          context.puts("{{x}} Unable to clone the repository.")
        end
      end

      def self.install_dependencies
        ArgoSetupStep.default do |context, _identifier, _directory_name, js_system|
          ShopifyCLI::JsDeps.new(ctx: context, system: js_system).install
        end
      end

      def self.initialize_project
        ArgoSetupStep.default do |context, identifier, _directory_name, js_system|
          frame_title = context.message("create.setup_project_frame_title")
          failure_message = context.message("features.argo.initialization_error")

          result = true
          CLI::UI::Frame.open(frame_title, failure_text: failure_message) do
            result = js_system.call(
              yarn: YARN_INITIALIZE_COMMAND + [INITIALIZE_TYPE_PARAMETER % identifier],
              npm: NPM_INITIALIZE_COMMAND + [INITIALIZE_TYPE_PARAMETER % identifier]
            )
          end

          result
        end
      end
    end
  end
end
