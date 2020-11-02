# frozen_string_literal: true

module Script
  module Commands
    class Enable < ShopifyCli::Command
      options do |parser, flags|
        parser.on('--config_props=KEYVALUEPAIRS', Array) { |t| flags[:config_props] = t }
        parser.on('--config_file=CONFIGFILEPATH') { |t| flags[:config_file] = t }
      end

      def call(_args, _name)
        ShopifyCli::Tasks::EnsureEnv.call(@ctx, required: [:api_key, :secret, :shop])
        project = ScriptProject.current
        api_key = project.env[:api_key]
        shop_domain = project.env[:shop]

        Layers::Application::EnableScript.call(
          ctx: @ctx,
          api_key: api_key,
          shop_domain: shop_domain,
          configuration: acquire_configuration(**slice(options.flags, :config_file, :config_props)),
          extension_point_type: project.extension_point_type,
          title: project.script_name
        )
        @ctx.puts(@ctx.message(
          'script.enable.script_enabled',
          api_key: api_key,
          shop_domain: shop_domain,
          type: project.extension_point_type.capitalize,
          title: project.script_name
        ))
        @ctx.puts(@ctx.message('script.enable.info'))
      rescue Errors::InvalidConfigYAMLError => e
        UI::ErrorHandler.pretty_print_and_raise(e)
      rescue StandardError => e
        UI::ErrorHandler.pretty_print_and_raise(e, failed_op: @ctx.message('script.enable.error.operation_failed'))
      end

      def self.help
        ShopifyCli::Context.message('script.enable.help', ShopifyCli::TOOL_NAME)
      end

      private

      def acquire_configuration(config_file: nil, config_props: nil)
        properties = {}
        properties = YAML.load(File.read(config_file)) unless config_file.nil?
        properties = properties.merge(parse_config_props(config_props)) unless config_props.nil?

        configuration = { entries: [] }
        properties.each do |key, value|
          configuration[:entries].push({
            key: key,
            value: value,
          })
        end
        configuration
      rescue Errno::ENOENT, Psych::SyntaxError
        raise Errors::InvalidConfigYAMLError, options.flags[:config_file]
      end

      def parse_config_props(config_props)
        Hash[
          config_props.map do |s|
            args = s.split(':').map(&:strip)
            raise Errors::InvalidConfigProps unless args.size == 2
            args
          end
        ]
      end

      # No slice pre Ruby 2.5 so roll our own
      def slice(hash, *keys)
        Hash[hash.to_a - hash.select { |key, _value| !keys.include?(key) }.to_a]
      end
    end
  end
end
