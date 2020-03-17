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
      CLI::UI::Frame.open("Installing dependencies with #{yarn? ? 'yarn' : 'npm'}...") do
        yarn? ? yarn : npm
      end
      ctx.done("Dependencies installed")
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
              ctx.error("expected to have a file at: #{package_json}")
            end

      deps = %w(dependencies devDependencies).map do |key|
        pkg.fetch(key, []).keys
      end.flatten
      CLI::UI::Spinner.spin("Installing #{deps.size} dependencies...") do |spinner|
        ctx.system('npm', 'install', '--no-audit', '--no-optional', '--silent', chdir: ctx.root)
        spinner.update_title("#{deps.size} npm dependencies installed")
      end
    rescue JSON::ParserError
      ctx.puts(
        "{{info:#{File.read(File.join(path, 'package.json'))}}} was not valid JSON. Fix this then try again",
        error: true
      )
      raise ShopifyCli::AbortSilent
    end
  end
end
