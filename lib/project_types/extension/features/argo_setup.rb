# frozen_string_literal: true

module Extension
  module Features
    class ArgoSetup
      include SmartProperties

      GIT_DIRECTORY = ".git"
      SCRIPTS_DIRECTORY = "scripts"

      property! :git_template, accepts: String
      property! :dependency_checks, default: -> { [] }

      def call(directory_name, identifier, context)
        steps = [
          ArgoSetupSteps.check_dependencies(dependency_checks),
          ArgoSetupSteps.clone_template(git_template),
          ArgoSetupSteps.install_dependencies,
          ArgoSetupSteps.initialize_project,
        ]

        install_result = run_install_steps(context, steps, identifier, directory_name)

        cleanup(context, install_result, directory_name)
        install_result
      end

      def run_install_steps(context, steps, identifier, directory_name)
        system = ShopifyCLI::JsSystem.new(ctx: context)

        steps.inject(true) do |success, setup_step|
          success && setup_step.call(context, identifier, directory_name, system)
        end
      end

      def cleanup(context, install_result, directory_name)
        install_result ? cleanup_template(context) : cleanup_on_failure(context, directory_name)
      end

      def cleanup_template(context)
        context.rm_r(GIT_DIRECTORY)
        context.rm_r(SCRIPTS_DIRECTORY)
      rescue Errno::ENOENT => e
        context.debug(e)
      end

      def cleanup_on_failure(context, directory_name)
        FileUtils.rm_r(directory_name) if Dir.exist?(directory_name)
      rescue Errno::ENOENT => e
        context.debug(e)
      end
    end
  end
end
