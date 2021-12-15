# frozen_string_literal: true

module ShopifyCLI
  class PartnersAPI
    class AppExtensions
      class ThreadPool
        NUMBER_OF_THREADS = 10

        def initialize
          @jobs = Queue.new
          @pool = Array.new(NUMBER_OF_THREADS) { spawn_thread }
        end

        def schedule(&block)
          @jobs << block
        end

        def shutdown
          NUMBER_OF_THREADS.times do
            schedule { throw(:stop_thread) }
          end
          @pool.map(&:join)
        end

        private

        def spawn_thread
          Thread.new do
            catch(:stop_thread) do
              loop { @jobs.pop.call }
            end
          end
        end
      end
    end
  end
end
