# frozen_string_literal: true

module ShopifyCLI
  class ThreadPool
    attr_reader :errors

    def initialize(pool_size: 10)
      @jobs = Queue.new
      @pool = Array.new(pool_size) { spawn_thread }
    end

    def schedule(job)
      @jobs << job
    end

    def shutdown
      @pool.size.times do
        schedule(-> { throw(:stop_thread) })
      end
      @pool.map(&:join)
    ensure
      @jobs.close
    end

    private

    def spawn_thread
      Thread.new do
        catch(:stop_thread) do
          loop { perform(@jobs.pop) }
        end
      end
    end

    def perform(job)
      job.call
      reschedule(job) if job.recurring?
    end

    def reschedule(job)
      wait(job.interval)
      schedule(job)
    end

    def wait(seconds)
      sleep(seconds)
    end
  end
end
