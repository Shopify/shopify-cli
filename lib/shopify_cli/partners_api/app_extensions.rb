# frozen_string_literal: true

require "shopify_cli/thread_pool"

require_relative "app_extensions/job"

module ShopifyCLI
  class PartnersAPI
    class AppExtensions
      class << self
        def fetch_apps_extensions(ctx, org, type)
          jobs = apps(org).map { |app| AppExtensions::Job.new(ctx, app, type) }

          consume_jobs!(jobs)
          patch_apps_with_extensions!(jobs)

          org
        end

        private

        def apps(org)
          (org && org["apps"]) || []
        end

        def consume_jobs!(jobs)
          thread_pool = ShopifyCLI::ThreadPool.new(pool_size: 1)
          jobs.each do |job|
            thread_pool.schedule(job)
          end
          thread_pool.shutdown

          raise_if_any_error(jobs)
        end

        def patch_apps_with_extensions!(jobs)
          jobs.each(&:patch_app_with_extensions!)
        end

        def raise_if_any_error(jobs)
          jobs.find(&:error?).tap { |job| raise job.error if job }
        end
      end
    end
  end
end
