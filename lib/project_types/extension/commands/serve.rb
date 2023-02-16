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
        parser.on("--generate-tmp-theme", "Populate host theme, created by CLI 3, with assets") do |generate_tmp_theme|
          flags[:generate_tmp_theme] = generate_tmp_theme
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
        parser.on("--extension-title=EXTENSION_TITLE", "The title of the extension") do |extension_title|
          flags[:extension_title] = extension_title.gsub('"', "")
        end
        parser.on("--extension-type=EXTENSION_TYPE", "The type of the extension") do |extension_type|
          flags[:extension_type] = extension_type.gsub('"', "")
        end
      end

      class RuntimeConfiguration
        include SmartProperties

        property :tunnel_url, accepts: String, default: nil
        property :resource_url, accepts: String, default: nil
        property! :tunnel_requested, accepts: [true, false], reader: :tunnel_requested?, default: true
        property :port, accepts: (1...(2**16))
        property :theme, accepts: String, default: nil
        property :generate_tmp_theme, accepts: [true, false], reader: :generate_tmp_theme?, default: false
        property :api_key, accepts: String, default: nil
        property :api_secret, accepts: String, default: nil
        property :registration_id, accepts: String, default: nil
        property :extension_title, accepts: String, default: nil
        property :extension_type, accepts: String, default: nil
      end

      def call(args, _command_name)
        @ctx.root = args.first || @ctx.root

        config = RuntimeConfiguration.new(
          tunnel_requested: tunnel_requested?,
          resource_url: options.flags[:resource_url],
          port: options.flags[:port],
          theme: options.flags[:theme],
          generate_tmp_theme: generate_tmp_theme?,
          api_key: options.flags[:api_key],
          api_secret: options.flags[:api_secret],
          registration_id: options.flags[:registration_id],
          extension_title: options.flags[:extension_title],
          extension_type: options.flags[:extension_type],
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

      def project
        return super unless options.flags[:extension_type]

        @project ||= Extension::Loaders::Project.load(
          context: options.flags[:context],
          directory: @ctx.root,
          api_key: options.flags[:api_key],
          api_secret: options.flags[:api_secret],
          registration_id: options.flags[:registration_id],
          env: {
            ExtensionProjectKeys::TITLE_KEY => options.flags[:extension_title],
            ExtensionProjectKeys::REGISTRATION_ID_KEY => options.flags[:registration_id],
            ExtensionProjectKeys::SPECIFICATION_IDENTIFIER_KEY => options.flags[:extension_type],
          }
        )
      end

      def tunnel_requested?
        tunnel = options.flags[:tunnel]
        tunnel.nil? || !!tunnel
      end

      def generate_tmp_theme?
        options.flags[:generate_tmp_theme] == true
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
          generate_tmp_theme: runtime_configuration.generate_tmp_theme?,
          api_key: runtime_configuration.api_key,
          api_secret: runtime_configuration.api_secret,
          registration_id: runtime_configuration.registration_id,
          resource_url: runtime_configuration.resource_url,
          project: project,
        )
        runtime_configuration
      end
    end
  end
end
