# frozen_string_literal: true

module ShopifyCLI
  class ThreadPool
    class Job
      attr_reader :error, :interval

      def initialize(interval = 0)
        @interval = interval
      end

      def perform!
        raise "`#{self.class.name}#perform!' must be defined"
      end

      def call
        perform!
      rescue StandardError => error
        @error = error
      end

      def success?
        !@error
      end

      def error?
        !!@error
      end

      def recurring?
        !interval.zero?
      end
    end
  end
end
