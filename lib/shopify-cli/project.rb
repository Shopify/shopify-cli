# frozen_string_literal: true
require 'shopify_cli'

module ShopifyCli
  ##
  # ShopifyCli::Project captures the current project that the user is working on.
  # This class can be used to fetch and save project environment as well as the
  # project config `.shopify-cli.yml`.
  #
  class Project
    include SmartProperties
    NOT_IN_PROJECT =<<~MESSAGE
      {{x}} You are not in a Shopify app project
      {{yellow:{{*}}}}{{reset: Run}}{{cyan: shopify create}}{{reset: to create your app}}
    MESSAGE
    private_constant :NOT_IN_PROJECT

    class << self
      ##
      # will get an instance of the project that the user is currently operating
      # on. This is used for access to project resources.
      #
      # #### Returns
      #
      # * `project` - a Project instance if the user is currently in the project.
      #
      # #### Raises
      #
      # * `ShopifyCli::Abort` - If the cli is not currently in a project directory
      #   then this will be raised with a message implying that the user is not in
      #   a project directory.
      #
      # #### Example
      #
      #   project = ShopifyCli::Project.current
      #
      def current
        at(Dir.pwd)
      end

      ##
      # will fetch the project type of the current project. This is mostly used
      # for internal project type loading, you should not normally need this.
      #
      # #### Returns
      #
      # * `type` - a string of the name of the app identifier. i.e. [rails, node]
      #   This will be nil if the user is not in a current project.
      #
      # #### Example
      #
      #   type = ShopifyCli::Project.current_app_type
      #
      def current_project_type
        proj_dir = directory(Dir.pwd)
        return if proj_dir.nil?
        current.config['app_type'].to_sym
      end

      ##
      # writes out the `.shopify-cli.yml` file. You should use this when creating
      # a project type so that the rest of your project type commands will load
      # in this project, in the future.
      #
      # #### Parameters
      #
      # * `ctx` - the current running context of your command
      # * `identifier` - a string or symbol of your app type name
      #
      # #### Example
      #
      #   type = ShopifyCli::Project.current_app_type
      #
      def write(ctx, identifier)
        require 'yaml' # takes 20ms, so deferred as late as possible.
        content = {
          'app_type' => identifier,
        }
        ctx.write('.shopify-cli.yml', YAML.dump(content))
      end

      private

      def directory(dir)
        @dir ||= Hash.new { |h, k| h[k] = __directory(k) }
        @dir[dir]
      end

      def at(dir)
        proj_dir = directory(dir)
        unless proj_dir
          raise(ShopifyCli::Abort, NOT_IN_PROJECT)
        end
        @at ||= Hash.new { |h, k| h[k] = new(directory: k) }
        @at[proj_dir]
      end

      def __directory(curr)
        loop do
          return nil if curr == '/'
          file = File.join(curr, '.shopify-cli.yml')
          return curr if File.exist?(file)
          curr = File.dirname(curr)
        end
      end
    end

    property :directory # :nodoc:

    ##
    # will read, parse and return the envfile for the project
    #
    # #### Returns
    #
    # * `env` - An instance of a ShopifyCli::Resources::EnvFile
    #
    # #### Example
    #
    #   ShopifyCli::Project.current.env
    #
    def env
      @env ||= Resources::EnvFile.read(directory)
    end

    ##
    # will read, parse and return the .shopify-cli.yml for the project
    #
    # #### Returns
    #
    # * `config` - A hash of configuration
    #
    # #### Raises
    #
    # * `ShopifyCli::Abort` - If the yml is invalid or poorly formatted
    # * `ShopifyCli::Abort` - If the yml file does not exist
    #
    # #### Example
    #
    #   ShopifyCli::Project.current.config
    #
    def config
      @config ||= begin
        config = load_yaml_file('.shopify-cli.yml')
        unless config.is_a?(Hash)
          raise ShopifyCli::Abort, '{{x}} .shopify-cli.yml was not a proper YAML file. Expecting a hash.'
        end
        config
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
