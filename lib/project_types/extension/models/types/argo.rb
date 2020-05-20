# frozen_string_literal: true
require 'base64'

module Extension
  module Models
    module Types
      class Argo
        include SmartProperties

        GIT_ADMIN_TEMPLATE = 'https://github.com/Shopify/shopify-app-extension-template.git'.freeze
        GIT_CHECKOUT_TEMPLATE = 'https://github.com/Shopify/argo-checkout-template.git'.freeze
        SCRIPT_PATH = %w(build main.js).freeze

        GIT_DIRECTORY = '.git'.freeze
        SCRIPTS_DIRECTORY = 'scripts'.freeze

        YARN_INITIALIZE_COMMAND = %w(yarn generate).freeze
        NPM_INITIALIZE_COMMAND = %w(npm run generate --).freeze
        INITIALIZE_TYPE_PARAMETER = '--type=%s'.freeze

        class << self
          def admin
            @admin ||= Argo.new(git_template: GIT_ADMIN_TEMPLATE)
          end

          def checkout
            @checkout ||= Argo.new(git_template: GIT_CHECKOUT_TEMPLATE)
          end
        end

        property! :git_template, accepts: String

        def create(directory_name, identifier, context)
          clone_template(directory_name, context)
          initialize_project(identifier, context)
          cleanup(context)
        end

        def config(context)
          filepath = File.join(context.root, SCRIPT_PATH)
          context.abort(context.message('features.argo.missing_file_error')) unless File.exists?(filepath)

          begin
            {
              serialized_script: Base64.strict_encode64(File.open(filepath).read.chomp)
            }
          rescue Exception
            context.abort(context.message('features.argo.script_prepare_error'))
          end
        end

        def clone_template(directory_name, context)
          ShopifyCli::Git.clone(git_template, directory_name, ctx: context)
          context.root = File.join(context.root, directory_name)
        end

        def initialize_project(identifier, context)
          JsDeps.install(context)

          initialize_command = JsDeps.new(ctx: context).yarn? ? YARN_INITIALIZE_COMMAND : NPM_INITIALIZE_COMMAND
          initialize_command = initialize_command + [INITIALIZE_TYPE_PARAMETER % identifier]

          CLI::UI::Frame.open(context.message('create.setup_project_frame_title')) do
            context.system(*initialize_command, chdir: context.root)
          end
        end

        def cleanup(context)
          begin
            context.rm_r(GIT_DIRECTORY)
            context.rm_r(SCRIPTS_DIRECTORY)
          rescue Errno::ENOENT => e
            context.debug(e)
          end
        end
      end
    end
  end
end
