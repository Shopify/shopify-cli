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
        parser.on("-p", "--port=PORT", "Specify the port to use") do |port|
          flags[:port] = port.to_i
        end
        parser.on("-T", "--theme=NAME_OR_ID", "Theme ID or name of the theme app extension host theme.") do |theme|
          flags[:theme] = theme
        end
        parser.on("--api-key=API_KEY", "Connect your extension and app by inserting your app's API key") do |api_key|
          flags[:api_key] = api_key.gsub('"', "")
        end
        parser.on("--api-secret=API_SECRET", "The API secret of the app the script is registered with.") do |api_secret|
          flags[:api_secret] = api_secret.gsub('"', "")
        end
        parser.on("--extension-id=EXTENSION_ID", "The id of the extension's registration.") do |registration_id|
          flags[:registration_id] = registration_id.gsub('"', "")
        end
      end

      class RuntimeConfiguration
        include SmartProperties

        property :tunnel_url, accepts: String, default: nil
        property :resource_url, accepts: String, default: nil
        property! :tunnel_requested, accepts: [true, false], reader: :tunnel_requested?, default: true
        property :port, accepts: (1...(2**16))
        property :theme, accepts: String, default: nil
        property :api_key, accepts: String, default: nil
        property :api_secret, accepts: String, default: nil
        property :registration_id, accepts: String, default: nil
      end

      def call(_args, _command_name)
        config = RuntimeConfiguration.new(
          tunnel_requested: tunnel_requested?,
          resource_url: options.flags[:resource_url],
          port: options.flags[:port],
          theme: options.flags[:theme],
          api_key: options.flags[:api_key],
          api_secret: options.flags[:api_secret],
          registration_id: options.flags[:registration_id]
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
        return runtime_configuration unless runtime_configuration.port.nil?
        return runtime_configuration unless specification_handler.choose_port?(@ctx)

        chosen_port = Tasks::ChooseNextAvailablePort
          .call(from: DEFAULT_PORT)
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
          theme: runtime_configuration.theme,
          api_key: runtime_configuration.api_key,
          api_secret: runtime_configuration.api_secret,
          registration_id: runtime_configuration.registration_id,
          resource_url: runtime_configuration.resource_url
        )
        runtime_configuration
      end
    end
  end
end
