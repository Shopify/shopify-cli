# frozen_string_literal: true

require_relative "app_extensions/job"
require_relative "app_extensions/thread_pool"

module ShopifyCLI
  class PartnersAPI
    class AppExtensions
      class << self
        def fetch_apps_extensions(ctx, orgs, type)
          jobs = apps(orgs).map { |app| AppExtensions::Job.new(ctx, app, type) }

          consume_jobs!(jobs)
          patch_apps_with_extensions!(jobs)

          orgs
        end

        private

        def apps(orgs)
          orgs.flat_map { |org| org["apps"] }
        end

        def consume_jobs!(jobs)
          thread_pool = AppExtensions::ThreadPool.new
          jobs.each do |job|
            thread_pool.schedule { job.fetch_extensions! }
          end
          thread_pool.shutdown
        end

        def patch_apps_with_extensions!(jobs)
          jobs.each(&:patch_app_with_extensions!)
        end
      end
    end
  end
end
