module Extension
  module Specifications
    module Handlers
      class Default
        attr_reader :specification

        def initialize(specification)
          @specification = specification
        end

        def graphql_identifier
          identifier
        end
  
        def identifier
          specification.identifier.to_sym
        end
  
        def name
          specification.name
        end
  
        def tagline
          message('tagline')
        end

        def title
          [name, tagline].compact.join(" - ")
        end
  
        def config(_context)
          raise NotImplementedError, "'#{__method__}' must be implemented for #{self.class}"
        end
  
        def create(_directory_name, _context)
          raise NotImplementedError, "'#{__method__}' must be implemented for #{self.class}"
        end
  
        def extension_context(_context)
          nil
        end
  
        def valid_extension_contexts
          []
        end
  
        private
  
        def message(key, *params)
          return unless messages.key?(key.to_sym)
          messages[key.to_sym] % params
        end
  
        def messages
          @messages ||= Messages::TYPES[identifier] || {}
        end
      end
    end
  end
end
