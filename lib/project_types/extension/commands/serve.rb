# frozen_string_literal: true

module Extension
  class Command
    class Serve < ExtensionCommand
      prerequisite_task ensure_project_type: :extension

      recommend_default_ruby_range

      DEFAULT_PORT = 39351

      options do |parser, flags|
        parser.on("-t", "--[no-]tunnel", "Establish an ngrok tunnel") { |tunnel| flags[:tunnel] = tunnel }
        parser.on("--resourceUrl=RESOURCE_URL", "Provide a resource URL") do |resource_url|
          flags[:resource_url] = resource_url
        end
      end

      class RuntimeConfiguration
        include SmartProperties

        property :tunnel_url, accepts: String, default: nil
        property :resource_url, accepts: String, default: nil
        property! :tunnel_requested, accepts: [true, false], reader: :tunnel_requested?, default: true
        property! :port, accepts: (1...(2**16)), default: DEFAULT_PORT
      end

      def call(_args, _command_name)
        config = RuntimeConfiguration.new(
          tunnel_requested: tunnel_requested?,
          resource_url: options.flags[:resource_url]
        )

        ShopifyCLI::Result
          .success(config)
          .then(&method(:find_available_port))
          .then(&method(:start_tunnel_if_required))
          .then(&method(:serve))
          .unwrap { |error| raise error }
      end

      def self.help
        ShopifyCLI::Context.new.message("serve.help", ShopifyCLI::TOOL_NAME)
      end

      private

      def tunnel_requested?
        tunnel = options.flags[:tunnel]
        tunnel.nil? || !!tunnel
      end

      def find_available_port(runtime_configuration)
        return runtime_configuration unless specification_handler.choose_port?(@ctx)

        chosen_port = Tasks::ChooseNextAvailablePort
          .call(from: runtime_configuration.port)
          .unwrap { |_error| @ctx.abort(@ctx.message("serve.no_available_ports_found")) }
        runtime_configuration.tap { |c| c.port = chosen_port }
      end

      def start_tunnel_if_required(runtime_configuration)
        return runtime_configuration unless specification_handler.establish_tunnel?(@ctx)
        return runtime_configuration unless runtime_configuration.tunnel_requested?

        return start_tunnel(runtime_configuration) if can_start_tunnel?(runtime_configuration)
        @ctx.abort(@ctx.message("serve.tunnel_already_running"))
      end

      def can_start_tunnel?(runtime_configuration)
        return true if ShopifyCLI::Tunnel.urls.empty?
        ShopifyCLI::Tunnel.running_on?(runtime_configuration.port)
      end

      def start_tunnel(runtime_configuration)
        tunnel_url = ShopifyCLI::Tunnel.start(@ctx, port: runtime_configuration.port)
        runtime_configuration.tap { |c| c.tunnel_url = tunnel_url }
      end

      def serve(runtime_configuration)
        specification_handler.serve(
          context: @ctx,
          tunnel_url: runtime_configuration.tunnel_url,
          port: runtime_configuration.port,
          resource_url: runtime_configuration.resource_url
        )
        runtime_configuration
      end
    end
  end
end
