# frozen_string_literal: true
require "project_types/extension/loaders/project"
require "project_types/extension/loaders/specification_handler"
require "shopify_cli/partners_api"

module ShopifyCLI
  module Theme
    module Extension
      class Syncer
        class ExtensionServeJob < ThreadPool::Job
          POLL_FREQUENCY = 1 # second
          PUSH_INTERVAL = 5 # seconds

          RESPONSE_FIELD = %w(data extensionUpdateDraft)
          VERSION_FIELD = "extensionVersion"
          USER_ERRORS_FIELD = "userErrors"

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
              @ctx.error("ERROR: #{user_errors.first["message"]}")
            else
              @ctx.done("Synced Extension")
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
        end
      end
    end
  end
end
