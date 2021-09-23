require "shopify_cli"

module ShopifyCLI
  ##
  # ShopifyCLI::PHPDeps ensures that all PHP dependencies are installed for projects.
  #
  class PHPDeps
    include SmartProperties

    property! :ctx, accepts: ShopifyCLI::Context

    ##
    # Proxy to instance method ShopifyCLI::PHPDeps.new.install.
    #
    # #### Parameters
    # - `ctx`: running context from your command
    # - `verbose`: whether to run the installation tools in verbose mode
    #
    # #### Example
    #
    #   ShopifyCLI::PHPDeps.install(ctx)
    #
    def self.install(ctx, verbose = false)
      new(ctx: ctx).install(verbose)
    end

    ##
    # Installs all of a project's PHP dependencies using Composer.
    #
    # #### Parameters
    # - `verbose`: whether to run the installation tools in verbose mode
    #
    # #### Example
    #
    #   # context is the running context for the command
    #   ShopifyCLI::PHPDeps.new(context).install(true)
    #
    def install(verbose = false)
      title = ctx.message("core.php_deps.installing")
      success = ctx.message("core.php_deps.installed")
      failure = ctx.message("core.php_deps.error.install_error")

      CLI::UI::Frame.open(title, success_text: success, failure_text: failure) do
        composer(verbose)
      end
    end

    private

    def composer(verbose = false)
      cmd = %w(composer install)
      cmd << "--quiet" unless verbose

      run_install_command(cmd)
    end

    def run_install_command(cmd)
      deps = parse_dependencies
      errors = nil

      spinner_title = ctx.message("core.php_deps.installing")
      success = CLI::UI::Spinner.spin(spinner_title, auto_debrief: false) do |spinner|
        _out, errors, status = CLI::Kit::System.capture3(*cmd, env: @ctx.env, chdir: ctx.root)
        update_spinner_title_and_status(spinner, status, deps)
      end

      errors.lines.each { |e| ctx.puts e } unless success || errors.nil?

      ctx.abort(ctx.message("core.php_deps.error.install", "Composer")) unless success
      success
    end

    def update_spinner_title_and_status(spinner, status, deps)
      if status.success?
        spinner.update_title(ctx.message("core.php_deps.installed_count", deps.size))
      else
        spinner.update_title(ctx.message("core.php_deps.error.install_spinner_error", deps.size))
        CLI::UI::Spinner::TASK_FAILED
      end
    end

    def parse_dependencies
      composer_json = File.join(ctx.root, "composer.json")
      pkg =
        begin
          JSON.parse(File.read(composer_json))
        rescue Errno::ENOENT, Errno::ENOTDIR
          ctx.abort(ctx.message("core.php_deps.error.missing_package", composer_json))
        end

      %w(require require-dev).map do |key|
        pkg.fetch(key, []).keys
      end.flatten
    rescue JSON::ParserError
      ctx.puts(
        ctx.message("core.php_deps.error.invalid_package", File.read(File.join(path, "composer.json"))),
        error: true
      )
      raise ShopifyCLI::AbortSilent
    end
  end
end
