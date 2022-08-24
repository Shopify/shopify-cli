# frozen_string_literal: true
require "project_types/extension/loaders/project"
require "project_types/extension/loaders/specification_handler"
require "shopify_cli/partners_api"
require "shopify_cli/thread_pool/job"

module ShopifyCLI
  module Theme
    module Extension
      class Syncer
        class ExtensionServeJob < ThreadPool::Job
          POLL_FREQUENCY = 0.5 # second
          PUSH_INTERVAL = 5 # seconds

          RESPONSE_FIELD = %w(data extensionUpdateDraft)
          VERSION_FIELD = "extensionVersion"
          USER_ERRORS_FIELD = "userErrors"
          ERROR_FILE_REGEX = /\[([^\]\[]*)\]/

          def initialize(ctx, syncer:, extension:)
            super(POLL_FREQUENCY)

            @ctx = ctx
            @extension = extension
            @syncer = syncer

            @mut = Mutex.new
          end

          def perform!
            return if @syncer.pending_updates.empty? # if no updates
            return if Time.now - @syncer.latest_sync < PUSH_INTERVAL

            project = ::Extension::Loaders::Project.load(
              context: @ctx,
              directory: Dir.pwd,
              api_key: nil,
              api_secret: nil,
              registration_id: nil,
            )

            specification_handler = ::Extension::Loaders::SpecificationHandler.load(project: project, context: @ctx)

            input = {
              api_key: project.app.api_key,
              registration_id: project.registration_id,
              config: JSON.generate(specification_handler.config(@ctx)),
              extension_context: specification_handler.extension_context(@ctx),
            }
            response = ShopifyCLI::PartnersAPI.query(@ctx, "extension_update_draft", **input).dig(*RESPONSE_FIELD)
            user_errors = response.dig(USER_ERRORS_FIELD)

            if user_errors
              @ctx.puts(error_message(project.title))
              error_files = erroneous_files(user_errors)
              print_items(error_files)
            else
              @ctx.puts(success_message(project.title))
              print_items({}.freeze)
              ::Extension::Tasks::Converters::VersionConverter.from_hash(@ctx, response.dig(VERSION_FIELD))
            end

            @mut.synchronize do
              @syncer.pending_updates.clear
              @syncer.latest_sync = Time.now
            end
          end

          private

          def timestamp
            Time.now.strftime("%T")
          end

          def success_message(project)
            "#{timestamp} {{green:Pushed}} {{>}} {{blue:'#{project}'}} to a draft"
          end

          def error_message(project)
            "#{timestamp} {{red:Error}}  {{>}} {{blue:'#{project}'}} could not be pushed:"
          end

          def print_file_success(file)
            @ctx.puts("{{blue:- #{file.relative_path}}}")
          end

          def print_file_error(file, err)
            @ctx.puts("{{red:- #{file.relative_path}}}")
            @ctx.puts("{{red:  - Cause: #{err}}}")
          end

          def erroneous_files(errors)
            files = {}
            errors.each do |e|
              path = e["message"][ERROR_FILE_REGEX, 1]
              file = @extension[path]
              files[file] = e["message"]
            end
            files
          end

          def print_items(erroneous_files)
            @syncer.pending_updates.each do |file|
              err = erroneous_files.dig(file)
              if err
                print_file_error(file, err)
                erroneous_files.delete(file)
              else
                print_file_success(file)
              end
            end
            erroneous_files.each do |file, err|
              print_file_error(file, err)
            end
          end
        end
      end
    end
  end
end
