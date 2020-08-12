# frozen_string_literal: true
require 'shopify_cli'

module Rails
  class Gem
    include SmartProperties

    property :ctx, accepts: ShopifyCli::Context, required: true
    property :name, converts: :to_s, required: true
    property :version, converts: :to_s

    class << self
      def install(ctx, *args)
        name = args.shift
        version = args.shift
        gem = new(ctx: ctx, name: name, version: version)
        ctx.debug(ctx.message('rails.gem.installed_debug', name, gem.installed?))
        gem.installed? ? true : gem.install!
      end

      def binary_path_for(ctx, binary)
        path_to_binary = File.join(gem_home(ctx), 'bin', binary)
        File.exist?(path_to_binary) ? path_to_binary : binary
      end

      def gem_home(ctx)
        ctx.getenv('GEM_HOME') || apply_gem_home(ctx)
      end

      def gem_path(ctx)
        ctx.getenv('GEM_PATH') || apply_gem_path(ctx)
      end

      private

      def apply_gem_home(ctx)
        path = File.join(ctx.getenv('HOME'), '.gem', 'ruby', RUBY_VERSION)
        ctx.mkdir_p(path) unless Dir.exist?(path)
        ctx.debug(ctx.message('rails.gem.setting_gem_home', path))
        ctx.setenv('GEM_HOME', path)
      end

      def apply_gem_path(ctx)
        path = ''
        out, stat = ctx.capture2('gem', 'environment', 'path')
        if stat
          path = out&.empty? ? '' : out.strip
        end
        ctx.debug(ctx.message('rails.gem.setting_gem_path', path))
        ctx.setenv('GEM_PATH', path)
      end
    end

    def installed?
      ctx.debug(
        ctx.message('rails.gem.checking_installation_path', "#{self.class.gem_home(ctx)}/gems/", name)
      )
      found = !!Dir.glob("#{self.class.gem_home(ctx)}/gems/#{name}-*").detect do |f|
        gem_satisfies_version?(f)
      end
      unless found
        # not found in GEM_HOME, check directories of GEM_PATH
        paths = self.class.gem_path(ctx).split(File::PATH_SEPARATOR)
        paths.each do |path|
          ctx.debug(ctx.message('rails.gem.checking_installation_path', "#{path}/gems/", name))
          found = !!Dir.glob("#{path}/gems/#{name}-*").detect do |f|
            gem_satisfies_version?(f)
          end
          break if found
        end
      end
      found
    end

    def install!
      spin = CLI::UI::SpinGroup.new
      spin.add(ctx.message('rails.gem.installing', name)) do |spinner|
        args = %w(gem install)
        args.push(name)
        unless version.nil?
          if ctx.windows? && version.include?('~')
            args.push('-v', "\"#{version}\"")
          else
            args.push('-v', version)
          end
        end
        ctx.system(*args)
        spinner.update_title(ctx.message('rails.gem.installed', name))
      end
      spin.wait
    end

    def gem_satisfies_version?(path)
      if version
        # there was a specific version given during new(), so
        # check version of gem found to determine match
        require 'semantic/semantic'
        found_version = %r{/#{Regexp.quote(name)}-([\d\.]+)}.match(path)[1]
        Semantic::Version.new(found_version).satisfies?(version)
      else
        # otherwise ignore the actual version number,
        # just check there's an initial digit
        %r{/#{Regexp.quote(name)}-\d}.match?(path)
      end
    end
  end
end
