# frozen_string_literal: true
require 'base64'

module Extension
  module Features
    class ArgoSetup
      include SmartProperties

      GIT_DIRECTORY = '.git'.freeze
      SCRIPTS_DIRECTORY = 'scripts'.freeze

      YARN_INITIALIZE_COMMAND = %w(generate).freeze
      NPM_INITIALIZE_COMMAND = %w(run generate --).freeze
      INITIALIZE_TYPE_PARAMETER = '--type=%s'.freeze

      property! :git_template, accepts: String
      property! :dependency_checks, default: []

      attr_accessor :success

      def call(directory_name, identifier, context)
        @success = true

        check_dependencies(context)
        clone_template(directory_name, context)
        initialize_project(identifier, context)
        cleanup(context, directory_name)

        @success
      end

      def check_dependencies(context)
        dependency_checks.each do |dependency_check|
          dependency_check.call(context)
        end
      end

      def clone_template(directory_name, context)
        ShopifyCli::Git.clone(git_template, directory_name, ctx: context)
        context.root = File.join(context.root, directory_name)
      end

      def initialize_project(identifier, context)
        system = ShopifyCli::JsSystem.new(ctx: context)
        ShopifyCli::JsDeps.new(ctx: context, system: system).install

        frame_title = context.message('create.setup_project_frame_title')
        failure_message = context.message('features.argo.initialization_error')

        CLI::UI::Frame.open(frame_title, failure_text: failure_message) do
          @success = system.call(
            yarn: YARN_INITIALIZE_COMMAND + [INITIALIZE_TYPE_PARAMETER % identifier],
            npm: NPM_INITIALIZE_COMMAND + [INITIALIZE_TYPE_PARAMETER % identifier]
          )
        end
      end

      def cleanup(context, directory_name)
        @success ? cleanup_template(context) : cleanup_on_failure(context, directory_name)
      end

      def cleanup_template(context)
        begin
          context.rm_r(GIT_DIRECTORY)
          context.rm_r(SCRIPTS_DIRECTORY)
        rescue Errno::ENOENT => e
          context.debug(e)
        end
      end

      def cleanup_on_failure(context, directory_name)
        begin
          FileUtils.rm_r(directory_name) if Dir.exists?(directory_name)
        rescue Errno::ENOENT => e
          context.debug(e)
        end
      end
    end
  end
end
