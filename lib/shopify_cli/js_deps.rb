require "shopify_cli"

module ShopifyCLI
  ##
  # ShopifyCLI::JsDeps ensures that all JavaScript dependencies are installed for projects.
  #
  class JsDeps
    include SmartProperties

    property! :ctx, accepts: ShopifyCLI::Context
    property! :system, accepts: JsSystem, default: -> { JsSystem.new(ctx: ctx) }

    ##
    # Proxy to instance method ShopifyCLI::JsDeps.new.install.
    #
    # #### Parameters
    # - `ctx`: running context from your command
    # - `verbose`: whether to run the installation tools in silent mode
    #
    # #### Example
    #
    #   ShopifyCLI::JsDeps.install(ctx)
    #
    def self.install(ctx, verbose = false)
      new(ctx: ctx).install(verbose)
    end

    ##
    # Installs all of a project's JavaScript dependencies using Yarn or NPM, based on the project's settings.
    #
    # #### Parameters
    # - `verbose`: whether to run the installation tools in silent mode
    #
    # #### Example
    #
    #   # context is the running context for the command
    #   ShopifyCLI::JsDeps.new(context).install(true)
    #
    def install(verbose = false)
      title = ctx.message("core.js_deps.installing", @system.package_manager)
      success = ctx.message("core.js_deps.installed")
      failure = ctx.message("core.js_deps.error.install_error", @system.package_manager)

      CLI::UI::Frame.open(title, success_text: success, failure_text: failure) do
        @system.call(
          yarn: -> { yarn(verbose) },
          npm: -> { npm(verbose) }
        )
      end
    end

    private

    def yarn(verbose = false)
      cmd = %w(yarn install)
      cmd << "--silent" unless verbose

      run_install_command(cmd)
    end

    def npm(verbose = false)
      cmd = %w(npm install --no-audit)
      cmd << "--quiet" unless verbose

      run_install_command(cmd)
    end

    def run_install_command(cmd)
      deps = parse_dependencies
      errors = nil

      spinner_title = ctx.message("core.js_deps.installing", @system.package_manager)
      success = CLI::UI::Spinner.spin(spinner_title, auto_debrief: false) do |spinner|
        _, errors, status = CLI::Kit::System.capture3(*cmd, env: @ctx.env, chdir: ctx.root)
        update_spinner_title_and_status(spinner, status, deps)
      end

      errors.lines.each { |e| ctx.puts e } unless success || errors.nil?
      success
    end

    def update_spinner_title_and_status(spinner, status, deps)
      if status.success?
        spinner.update_title(ctx.message("core.js_deps.installed", deps.size))
      else
        spinner.update_title(ctx.message("core.js_deps.error.install_spinner_error", deps.size))
        CLI::UI::Spinner::TASK_FAILED
      end
    end

    def parse_dependencies
      package_json = File.join(ctx.root, "package.json")
      pkg = begin
              JSON.parse(File.read(package_json))
            rescue Errno::ENOENT, Errno::ENOTDIR
              ctx.abort(ctx.message("core.js_deps.error.missing_package", package_json))
            end

      %w(dependencies devDependencies).map do |key|
        pkg.fetch(key, []).keys
      end.flatten
    rescue JSON::ParserError
      ctx.puts(
        ctx.message("core.js_deps.error.invalid_package", File.read(File.join(path, "package.json"))),
        error: true
      )
      raise ShopifyCLI::AbortSilent
    end
  end
end
