require 'shopify_cli'

module ShopifyCli
  ##
  # ShopifyCli::JsSystem allows conditional system calls of npm or yarn commands.
  #
  class JsSystem
    include SmartProperties

    YARN_CORE_COMMAND = 'yarn'
    NPM_CORE_COMMAND = 'npm'

    class << self
      ##
      # Proxy to instance method `ShopifyCli::JsSystem.new.yarn?`
      #
      # #### Parameters
      # - `ctx`: running context from your command
      #
      # #### Example
      #
      #   ShopifyCli::JsSystem.yarn?(ctx)
      #
      def yarn?(ctx)
        JsSystem.new(ctx: ctx).yarn?
      end

      ##
      # Proxy to instance method `ShopifyCli::JsSystem.new.call`
      #
      # #### Parameters
      # - `ctx`: running context from your command
      # - `yarn`: The proc, array, or string command to run if yarn is available
      # - `npm`: The proc, array, or string command to run if npm is available
      #
      # #### Example
      #
      #   ShopifyCli::JsSystem.call(ctx, yarn: ['install', '--silent'], npm: ['install', '--no-audit'])
      #
      def call(ctx, yarn:, npm:)
        JsSystem.new(ctx: ctx).call(yarn: yarn, npm: npm)
      end
    end

    property :ctx, accepts: ShopifyCli::Context

    ##
    # Returns the name of the JS package manager being used
    #
    # #### Example
    #
    #   ShopifyCli::JsSystem.new(ctx: ctx).package_manager
    #
    def package_manager
      yarn? ? YARN_CORE_COMMAND : NPM_CORE_COMMAND
    end

    ##
    # Returns true if yarn is available and false otherwise
    #
    # #### Example
    #
    #   ShopifyCli::JsSystem.new(ctx: ctx).yarn?
    #
    def yarn?
      @has_yarn ||= begin
        cmd_path = @ctx.which('yarn')
        File.exist?(File.join(ctx.root, 'yarn.lock')) && !cmd_path.nil?
      end
    end

    ##
    # Runs a command with the proper JS package manager depending on the result of `yarn?`
    #
    # #### Parameters
    # - `ctx`: running context from your command
    # - `yarn`: The proc, array, or string command to run if yarn is available
    # - `npm`: The proc, array, or string command to run if npm is available
    #
    # #### Example
    #
    #   ShopifyCli::JsSystem.new(ctx: ctx).call(yarn: ['install', '--silent'], npm: ['install', '--no-audit'])
    #
    def call(yarn:, npm:)
      yarn? ? call_command(yarn, YARN_CORE_COMMAND) : call_command(npm, NPM_CORE_COMMAND)
    end

    private

    def call_command(command, core_command)
      if command.is_a?(String) || command.is_a?(Array)
        CLI::Kit::System.system(core_command, *command, chdir: ctx.root).success?
      else
        command.call
      end
    end
  end
end
