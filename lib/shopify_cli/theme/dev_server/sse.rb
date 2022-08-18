# frozen_string_literal: true
require "thread"

module ShopifyCLI
  module Theme
    class DevServer
      # Server-Sent events implementation for Rack.
      # Based on https://gist.github.com/raggi/ff7971991297e5c8a1ce
      class SSE
        class Event < Struct.new(:data)
          def to_s
            "data: #{data}\n" \
            "\n\n"
          end
        end

        class Stream
          def initialize(streams)
            @streams = streams
            @queue = Queue.new
          end

          def <<(event)
            raise TypeError, "expected SSE::Event" unless event.is_a?(Event)
            @queue << event
          end

          def each
            while (event = @queue.pop)
              yield event.to_s
            end
          end

          def close
            @streams.remove(self)
            @queue << nil
          end
        end

        class Streams
          def initialize
            @list = []
          end

          def size
            @list.size
          end

          def new
            stream = Stream.new(self)
            @list << stream
            stream
          end

          def remove(stream)
            raise TypeError, "expected SSE::Stream" unless stream.is_a?(Stream)
            @list.delete(stream)
          end

          def broadcast(data)
            raise TypeError, "expected String" unless data.is_a?(String)
            @list.each do |stream|
              stream << Event.new(data)
            end
          end

          def close
            @list.each(&:close)
            @list.clear
          end
        end
      end
    end
  end
end
