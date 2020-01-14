# frozen_string_literal: true
require 'shopify_cli'

module ShopifyCli
  class Project
    include SmartProperties

    class << self
      def current
        at(Dir.pwd)
      end

      def at(dir)
        proj_dir = directory(dir)
        unless proj_dir
          raise(ShopifyCli::Abort, "{{x}} #{message}")
        end
        @at ||= Hash.new { |h, k| h[k] = new(directory: k) }
        @at[proj_dir]
      end

      # Returns the directory of the project you are current in
      # Traverses up directory hierarchy until it finds a `.shopify-cli.yml`, then returns the directory is it in
      #
      # #### Example Usage
      # `directory`, e.g. `~/src/Shopify/dev`
      #
      def directory(dir)
        @dir ||= Hash.new { |h, k| h[k] = __directory(k) }
        @dir[dir]
      end

      def message
        <<~MESSAGE
          {{x}} You are not in a Shopify app project
          {{yellow:{{*}}}}{{reset: Run}}{{cyan: shopify create project}}{{reset: to create your app}}
        MESSAGE
      end

      def write(ctx, project_type, identifier)
        require 'yaml' # takes 20ms, so deferred as late as possible.
        content = {
          'project_type' => project_type,
          'app_type' => identifier,
        }
        ctx.write('.shopify-cli.yml', YAML.dump(content))
      end

      private

      def __directory(curr)
        loop do
          return nil if curr == '/'
          file = File.join(curr, '.shopify-cli.yml')
          return curr if File.exist?(file)
          curr = File.dirname(curr)
        end
      end
    end

    property :directory

    def app_type
      ShopifyCli::AppTypeRegistry[app_type_id]
    end

    def app_type_id
      config['app_type'].to_sym
    end

    def env
      @env ||= Helpers::EnvFile.read(directory)
    end

    def config
      @config ||= begin
        defaults = {
          'project_type' => :app,
        }
        config = load_yaml_file('.shopify-cli.yml')
        unless config.is_a?(Hash)
          raise ShopifyCli::Abort, '{{x}} .shopify-cli.yml was not a proper YAML file. Expecting a hash.'
        end
        defaults.merge(config)
      end
    end

    private

    def load_yaml_file(relative_path)
      f = File.join(directory, relative_path)
      require 'yaml' # takes 20ms, so deferred as late as possible.
      begin
        YAML.load_file(f)
      rescue Psych::SyntaxError => e
        raise(ShopifyCli::Abort, "{{x}} #{relative_path} contains invalid YAML: #{e.message}")
      # rescue Errno::EACCES => e
      # TODO
      #   Dev::Helpers::EaccesHandler.diagnose_and_raise(f, e, mode: :read)
      rescue Errno::ENOENT
        raise ShopifyCli::Abort, "{{x}} #{f} not found"
      end
    end
  end
end
