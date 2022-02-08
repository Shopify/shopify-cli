# frozen_string_literal: true
require "shopify_cli"

module Rails
  class Gem
    include SmartProperties

    property :ctx, accepts: ShopifyCLI::Context, required: true
    property :name, converts: :to_s, required: true
    property :version, converts: :to_s

    class << self
      def install(ctx, *args)
        name = args.shift
        version = args.shift
        gem = new(ctx: ctx, name: name, version: version)
        ctx.debug(ctx.message("rails.gem.installed_debug", name, gem.installed?))
        gem.installed? ? true : gem.install!
      end

      def binary_path_for(ctx, binary)
        path_to_binary = File.join(gem_home(ctx), "bin", binary)
        File.exist?(path_to_binary) ? path_to_binary : binary
      end

      def gem_home(ctx)
        ctx.getenv("GEM_HOME") || apply_gem_home(ctx)
      end

      def gem_path(ctx)
        ctx.getenv("GEM_PATH") || apply_gem_path(ctx)
      end

      private

      def apply_gem_home(ctx)
        path = ""
        # extract GEM_HOME from `gem environment home` command
        out, stat = ctx.capture2e("gem", "environment", "home")
        path = out&.empty? ? "" : out.strip if stat.success?
        # fallback if return from `gem environment home` is empty (somewhat unlikely)
        path = fallback_gem_home_path(ctx) if path.empty?
        # fallback if path isn't writable (if using a system installed ruby)
        path = fallback_gem_home_path(ctx) unless File.writable?(path)
        ctx.mkdir_p(path) unless Dir.exist?(path)
        ctx.debug(ctx.message("rails.gem.setting_gem_home", path))
        ctx.setenv("GEM_HOME", path)
      end

      def apply_gem_path(ctx)
        path = ""
        out, stat = ctx.capture2e("gem", "environment", "path")
        path = out&.empty? ? "" : out.strip if stat.success?
        # usually GEM_PATH already contains GEM_HOME
        # if gem_home() falls back to our fallback path, we need to add it
        path = gem_home(ctx) + File::PATH_SEPARATOR + path unless path.include?(gem_home(ctx))
        ctx.debug(ctx.message("rails.gem.setting_gem_path", path))
        ctx.setenv("GEM_PATH", path)
      end

      def fallback_gem_home_path(ctx)
        File.join(ctx.getenv("HOME"), ".gem", "ruby", RUBY_VERSION)
      end
    end

    def installed?
      found = false
      paths = self.class.gem_path(ctx).split(File::PATH_SEPARATOR)
      paths.each do |path|
        ctx.debug(ctx.message("rails.gem.checking_installation_path", "#{path}/gems/", name))
        found = !!Dir.glob("#{path}/gems/#{name}-*").detect do |f|
          gem_satisfies_version?(f)
        end
        break if found
      end
      found
    end

    def install!
      spin = CLI::UI::SpinGroup.new
      spin.add(ctx.message("rails.gem.installing", name)) do |spinner|
        args = ["#{ENV["RUBY_BINDIR"]}gem", "install", name]
        unless version.nil?
          if ctx.windows? && version.include?("~")
            args.push("-v", "\"#{version}\"")
          else
            args.push("-v", version)
          end
        end
        ctx.system(*args)
        spinner.update_title(ctx.message("rails.gem.installed", name))
      end
      spin.wait
    end

    def gem_satisfies_version?(path)
      if version
        # there was a specific version given during new(), so
        # check version of gem found to determine match
        require "semantic/semantic"
        found_version, _ = path.match(%r{/#{Regexp.quote(name)}-(\d\.\d\.\d)})&.captures
        found_version.nil? ? false : Semantic::Version.new(found_version).satisfies?(version)
      else
        # otherwise ignore the actual version number,
        # just check there's an initial digit
        %r{/#{Regexp.quote(name)}-\d}.match?(path)
      end
    end
  end
end
