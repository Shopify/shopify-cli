require 'shopify_cli'

module ShopifyCli
  ##
  # ShopifyCli::JsDeps ensures that all JavaScript dependencies are installed for projects.
  #
  class JsDeps
    include SmartProperties

    property :ctx, accepts: ShopifyCli::Context, required: true

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
      CLI::UI::Frame.open(ctx.message('core.js_deps.installing', yarn? ? 'yarn' : 'npm')) do
        yarn? ? yarn(verbose) : npm(verbose)
      end
      ctx.done(ctx.message('core.js_deps.installed'))
    end

    private

    def yarn?
      File.exist?(File.join(ctx.root, 'yarn.lock')) && CLI::Kit::System.system('which', 'yarn').success?
    end

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
      CLI::UI::Spinner.spin(ctx.message('core.js_deps.npm_installing_deps', deps.size)) do |spinner|
        ctx.system(*cmd, chdir: ctx.root)
        spinner.update_title(ctx.message('core.js_deps.npm_installed_deps', deps.size))
      end
    rescue JSON::ParserError
      ctx.puts(
        ctx.message('core.js_deps.error.invalid_package', File.read(File.join(path, 'package.json'))),
        error: true
      )
      raise ShopifyCli::AbortSilent
    end
  end
end
