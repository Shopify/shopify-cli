require 'shopify_cli'

module Node
  class JsDeps
    include SmartProperties

    property :ctx, accepts: ShopifyCli::Context, required: true

    def self.install(ctx)
      new(ctx: ctx).install
    end

    def yarn?
      File.exist?(File.join(ctx.root, 'yarn.lock')) && CLI::Kit::System.system('which', 'yarn').success?
    end

    def install
      CLI::UI::Frame.open(ctx.message('node.js_deps.installing', yarn? ? 'yarn' : 'npm')) do
        yarn? ? yarn : npm
      end
      ctx.done(ctx.message('node.js_deps.installed'))
    end

    def yarn
      success = CLI::Kit::System.system('yarn', 'install', '--silent', chdir: ctx.root) do |out, err|
        puts out
        err.lines.each do |e|
          puts e
        end
      end.success?
      return false unless success
      true
    end

    def npm
      package_json = File.join(ctx.root, 'package.json')
      pkg = begin
              JSON.parse(File.read(package_json))
            rescue Errno::ENOENT, Errno::ENOTDIR
              ctx.abort(ctx.message('node.js_deps.error.missing_package', package_json))
            end

      deps = %w(dependencies devDependencies).map do |key|
        pkg.fetch(key, []).keys
      end.flatten
      CLI::UI::Spinner.spin(ctx.message('node.js_deps.npm_installing_deps', deps.size)) do |spinner|
        ctx.system('npm', 'install', '--no-audit', '--no-optional', '--silent', chdir: ctx.root)
        spinner.update_title(ctx.message('node.js_deps.npm_installed_deps', deps.size))
      end
    rescue JSON::ParserError
      ctx.puts(
        ctx.message('node.js_deps.error.invalid_package', File.read(File.join(path, 'package.json'))),
        error: true
      )
      raise ShopifyCli::AbortSilent
    end
  end
end
