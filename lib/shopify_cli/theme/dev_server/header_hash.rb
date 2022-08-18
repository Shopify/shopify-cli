# frozen_string_literal: true

module ShopifyCLI
  module Theme
    class DevServer
      # Based on Rack::HeaderHash
      class HeaderHash < Hash
        def self.[](headers)
          if headers.is_a?(HeaderHash) && !headers.frozen?
            headers
          else
            new(headers)
          end
        end

        def initialize(hash = {})
          super()
          @names = {}
          hash.each { |k, v| self[k] = v }
        end

        # on dup/clone, we need to duplicate @names hash
        def initialize_copy(other)
          super
          @names = other.names.dup
        end

        # on clear, we need to clear @names hash
        def clear
          super
          @names.clear
        end

        def each
          super do |k, v|
            yield(k, v.respond_to?(:to_ary) ? v.to_ary.join("\n") : v)
          end
        end

        def to_hash
          hash = {}
          each { |k, v| hash[k] = v }
          hash
        end

        def [](k)
          super(k) || super(@names[k.downcase])
        end

        def fetch(k, default = nil)
          self[k] || super(@names[k.downcase], default)
        end

        def []=(k, v)
          canonical = k.downcase.freeze
          # .delete is expensive, don't invoke it unless necessary
          delete(k) if @names[canonical] && @names[canonical] != k
          @names[canonical] = k
          super(k, v)
        end

        def delete(k)
          canonical = k.downcase
          result = super(@names.delete(canonical))
          result
        end

        def include?(k)
          super || @names.include?(k.downcase)
        end

        alias_method :has_key?, :include?
        alias_method :member?, :include?
        alias_method :key?, :include?

        def merge!(other)
          other.each { |k, v| self[k] = v }
          self
        end

        def merge(other)
          hash = dup
          hash.merge!(other)
        end

        def replace(other)
          clear
          other.each { |k, v| self[k] = v }
          self
        end

        protected

        attr_reader :names
      end
    end
  end
end
