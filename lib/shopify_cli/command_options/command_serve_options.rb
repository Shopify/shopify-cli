require "shopify_cli"

module ShopifyCLI
  module CommandOptions
    module CommandServeOptions
      def self.included(base)
        base.extend(ClassMethods)
        base.class_eval do
          def port
            return ShopifyCLI::Tunnel::PORT.to_s unless options.flags.key?(:port)
            port = options.flags[:port].to_i
            @ctx.abort(@ctx.message("core.app.serve.error.invalid_port", options.flags[:port])) unless port > 0
            port
          end

          def host
            host = options.flags[:host]
            unless host.nil?
              @ctx.abort(@ctx.message("core.app.serve.error.host_must_be_https")) if host.match(/^https/i).nil?
            end
            host
          end

          def no_update
            options.flags[:no_update] || false
          end
        end
      end

      module ClassMethods
        def parse_host_option
          options do |parser, flags|
            parser.on("--host=HOST") do |h|
              flags[:host] = h.gsub('"', "")
            end
          end
        end

        def parse_port_option
          options do |parser, flags|
            parser.on("--port=PORT") { |port| flags[:port] = port }
          end
        end

        def parse_no_update_option
          options do |parser, flags|
            parser.on("--no-update") { flags[:no_update] = true }
          end
        end
      end
    end
  end
end
