require "shopify_cli"

module ShopifyCLI
  ##
  # ShopifyCLI::JsSystem allows conditional system calls of npm or yarn commands.
  #
  class JsSystem
    include SmartProperties

    YARN_CORE_COMMAND = "yarn"
    NPM_CORE_COMMAND = "npm"

    class << self
      ##
      # Proxy to instance method `ShopifyCLI::JsSystem.new.yarn?`
      #
      # #### Parameters
      # - `ctx`: running context from your command
      #
      # #### Example
      #
      #   ShopifyCLI::JsSystem.yarn?(ctx)
      #
      def yarn?(ctx)
        JsSystem.new(ctx: ctx).yarn?
      end

      ##
      # Proxy to instance method `ShopifyCLI::JsSystem.new.call`
      #
      # #### Parameters
      # - `ctx`: running context from your command
      # - `yarn`: The proc, array, or string command to run if yarn is available
      # - `npm`: The proc, array, or string command to run if npm is available
      #
      # #### Example
      #
      #   ShopifyCLI::JsSystem.call(ctx, yarn: ['install', '--silent'], npm: ['install', '--no-audit'])
      #
      def call(ctx, yarn:, npm:, capture_response: false)
        JsSystem.new(ctx: ctx).call(yarn: yarn, npm: npm, capture_response: capture_response)
      end
    end

    property :ctx, accepts: ShopifyCLI::Context

    ##
    # Returns the name of the JS package manager being used
    #
    # #### Example
    #
    #   ShopifyCLI::JsSystem.new(ctx: ctx).package_manager
    #
    def package_manager
      yarn? ? YARN_CORE_COMMAND : NPM_CORE_COMMAND
    end

    ##
    # Returns true if yarn is available and false otherwise
    #
    # #### Example
    #
    #   ShopifyCLI::JsSystem.new(ctx: ctx).yarn?
    #
    def yarn?
      @has_yarn ||= begin
        cmd_path = @ctx.which("yarn")
        File.exist?(File.join(ctx.root, "yarn.lock")) && !cmd_path.nil?
      end
    end

    ##
    # Runs a command with the proper JS package manager depending on the result of `yarn?`
    #
    # #### Parameters
    # - `ctx`: running context from your command
    # - `yarn`: The proc, array, or string command to run if yarn is available
    # - `npm`: The proc, array, or string command to run if npm is available
    # - `capture_response`: The boolean flag to capture the output of the running command if it is set to true
    #
    # #### Example
    #
    #   ShopifyCLI::JsSystem.new(ctx: ctx).call(
    #     yarn: ['install', '--silent'],
    #     npm: ['install', '--no-audit'],
    #     capture_response: false
    #   )
    #
    def call(yarn:, npm:, capture_response: false)
      if yarn?
        call_command(yarn, YARN_CORE_COMMAND, capture_response)
      else
        call_command(npm, NPM_CORE_COMMAND, capture_response)
      end
    end

    private

    def call_command(command, core_command, capture_response)
      if command.is_a?(String) || command.is_a?(Array)
        capture_response ? call_with_capture(command, core_command) : call_without_capture(command, core_command)
      else
        command.call
      end
    end

    def call_with_capture(command, core_command)
      CLI::Kit::System.capture3(core_command, *command, chdir: ctx.root)
    end

    def call_without_capture(command, core_command)
      CLI::Kit::System.system(core_command, *command, chdir: ctx.root).success?
    end
  end
end
