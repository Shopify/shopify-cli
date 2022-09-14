# frozen_string_literal: true
require "shopify_cli"

module ShopifyCLI
  ##
  # ShopifyCLI::Project captures the current project that the user is working on.
  # This class can be used to fetch and save project environment as well as the
  # project config `.shopify-cli.yml`.
  #
  class Project
    include SmartProperties

    class << self
      ##
      # will get an instance of the project that the user is currently operating
      # on. This is used for access to project resources.
      #
      # #### Parameters
      #
      # * `force_reload` - whether to force a reload of the project files
      #
      # #### Returns
      #
      # * `project` - a Project instance if the user is currently in the project.
      #
      # #### Raises
      #
      # * `ShopifyCLI::Abort` - If the cli is not currently in a project directory
      #   then this will be raised with a message implying that the user is not in
      #   a project directory.
      #
      # #### Example
      #
      #   project = ShopifyCLI::Project.current
      #
      def current(force_reload: false)
        clear if force_reload
        at(Dir.pwd)
      end

      ##
      # will return true if the command line is currently within a project
      #
      # #### Returns
      #
      # * `has_current?` - boolean, true if there is a current project
      #
      def has_current?
        !directory(Dir.pwd).nil?
      end

      ##
      # will fetch the project type of the current project. This is mostly used
      # for internal project type loading, you should not normally need this.
      #
      # #### Returns
      #
      # * `type` - a symbol of the name of the project type identifier. i.e. [rails, node]
      #   This will be nil if the user is not in a current project.
      #
      # #### Example
      #
      #   type = ShopifyCLI::Project.current_project_type
      #
      def current_project_type
        return unless has_current?
        current.config["project_type"].to_sym
      end

      ##
      # writes out the `.shopify-cli.yml` file. You should use this when creating
      # a project type so that the rest of your project type commands will load
      # in this project, in the future.
      #
      # #### Parameters
      #
      # * `ctx` - the current running context of your command
      # * `project_type` - a string or symbol of your project type name
      # * `organization_id` - the id of the partner organization that the app is owned by. Used for metrics
      # * `identifiers` - an optional hash of other app identifiers
      #
      # #### Example
      #
      #   ShopifyCLI::Project.write(
      #     @ctx,
      #     project_type: "node",
      #     organization_id: form_data.organization_id,
      #   )
      #
      def write(ctx, project_type:, organization_id:, **identifiers)
        require "yaml" # takes 20ms, so deferred as late as possible.
        content = Hash[{ project_type: project_type, organization_id: organization_id.to_i }
          .merge(identifiers)
          .collect { |k, v| [k.to_s, v] }]
        content["shopify_organization"] = true if Shopifolk.acting_as_shopify_organization?

        ctx.write(".shopify-cli.yml", YAML.dump(content))
        clear
      end

      def project_name
        File.basename(current.directory)
      end

      def clear
        @at = nil
        @dir = nil
      end

      def at(dir)
        proj_dir = directory(dir)
        if !proj_dir && !ShopifyCLI::Environment.run_as_subprocess?
          raise(ShopifyCLI::Abort, Context.message("core.project.error.not_in_project"))
        end
        @at ||= Hash.new { |h, k| h[k] = new(directory: k) }
        @at[proj_dir]
      end

      private

      def directory(dir)
        @dir ||= Hash.new { |h, k| h[k] = Utilities.directory(".shopify-cli.yml", k) }
        @dir[dir]
      end
    end

    property :directory # :nodoc:
    property :env # :nodoc:

    ##
    # will read, parse and return the envfile for the project
    #
    # #### Returns
    #
    # * `env` - An instance of a ShopifyCLI::Resources::EnvFile
    #
    # #### Example
    #
    #   ShopifyCLI::Project.current.env
    #
    def env
      @env ||= begin
                 Resources::EnvFile.read(directory)
               rescue Errno::ENOENT
                 nil
               end
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
    # * `ShopifyCLI::Abort` - If the yml is invalid or poorly formatted
    # * `ShopifyCLI::Abort` - If the yml file does not exist
    #
    # #### Example
    #
    #   ShopifyCLI::Project.current.config
    #
    def config
      @config ||= begin
        config = load_yaml_file(".shopify-cli.yml")
        unless config.is_a?(Hash)
          raise ShopifyCLI::Abort, Context.message("core.yaml.error.not_hash", ".shopify-cli.yml")
        end

        # The app_type key was deprecated in favour of project_type, so replace it
        if config.key?("app_type")
          config["project_type"] = config["app_type"]
          config.delete("app_type")
        end

        config
      end
    end

    private

    def load_yaml_file(relative_path)
      f = File.join(directory, relative_path)
      require "yaml" # takes 20ms, so deferred as late as possible.
      begin
        YAML.load_file(f)
      rescue Psych::SyntaxError => e
        raise(ShopifyCLI::Abort, Context.message("core.yaml.error.invalid", relative_path, e.message))
      # rescue Errno::EACCES => e
      # TODO
      #   Dev::Helpers::EaccesHandler.diagnose_and_raise(f, e, mode: :read)
      rescue Errno::ENOENT
        raise ShopifyCLI::Abort, Context.message("core.yaml.error.not_found", f)
      end
    end
  end
end
