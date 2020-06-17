require 'shopify_cli'

module ShopifyCli
  ##
  # ShopifyCli::JsDeps ensures that all JavaScript dependencies are installed for projects.
  #
  class JsDeps
    include SmartProperties

    property! :ctx, accepts: ShopifyCli::Context
    property! :system, accepts: JsSystem, default: -> { JsSystem.new(ctx: ctx) }

    ##
    # Proxy to instance method ShopifyCli::JsDeps.new.install.
    #
    # #### Parameters
    # - `ctx`: running context from your command
    # - `verbose`: whether to run the installation tools in silent mode
    #
    # #### Example
    #
    #   ShopifyCli::JsDeps.install(ctx)
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
    #   ShopifyCli::JsDeps.new(context).install(true)
    #
    def install(verbose = false)
      title = ctx.message('core.js_deps.installing', @system.package_manager)
      success = ctx.message('core.js_deps.installed')
      failure = ctx.message('core.js_deps.error.install_error', @system.package_manager)

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
      cmd << '--silent' unless verbose

      CLI::Kit::System.system(*cmd, chdir: ctx.root) do |out, err|
        ctx.puts out
        err.lines.each do |e|
          ctx.puts e
        end
      end.success?
    end

    def npm(verbose = false)
      cmd = %w(npm install --no-audit --no-optional)
      cmd << '--silent' unless verbose

      package_json = File.join(ctx.root, 'package.json')
      pkg = begin
              JSON.parse(File.read(package_json))
            rescue Errno::ENOENT, Errno::ENOTDIR
              ctx.abort(ctx.message('core.js_deps.error.missing_package', package_json))
            end

      deps = %w(dependencies devDependencies).map do |key|
        pkg.fetch(key, []).keys
      end.flatten

      success = true
      spinner_title = ctx.message('core.js_deps.npm_installing_deps', deps.size)
      CLI::UI::Spinner.spin(spinner_title, auto_debrief: false) do |spinner|
        success = ctx.system(*cmd, chdir: ctx.root).success?

        if success
          spinner.update_title(ctx.message('core.js_deps.npm_installed_deps', deps.size))
        else
          spinner.update_title(ctx.message('core.js_deps.error.install_error'))
          CLI::UI::Spinner::TASK_FAILED
        end
      end

      success
    rescue JSON::ParserError
      ctx.puts(
        ctx.message('core.js_deps.error.invalid_package', File.read(File.join(path, 'package.json'))),
        error: true
      )
      raise ShopifyCli::AbortSilent
    end
  end
end
