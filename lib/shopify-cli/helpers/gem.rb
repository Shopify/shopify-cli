# frozen_string_literal: true
require 'shopify_cli'

module ShopifyCli
  module Helpers
    class Gem
      include SmartProperties

      property :ctx, accepts: ShopifyCli::Context
      property :name, converts: :to_s

      class << self
        def install(ctx, name)
          gem = new(ctx: ctx, name: name)
          ctx.debug("#{name} installed: #{gem.installed?}")
          gem.install! unless gem.installed?
        end

        def binary_path_for(ctx, binary)
          File.join(gem_home(ctx), 'bin', binary)
        end

        def gem_home(ctx)
          ctx.getenv('GEM_HOME') || apply_gem_home(ctx)
        end

        private

        def apply_gem_home(ctx)
          path = File.join(ctx.getenv('HOME'), '.gem', 'ruby', RUBY_VERSION)
          ctx.mkdir_p(path) unless Dir.exist?(path)
          ctx.setenv('GEM_HOME', path)
        end
      end

      def installed?
        !!Dir.glob("#{self.class.gem_home(ctx)}/gems/#{name}-*").detect do |f|
          f =~ %r{/#{Regexp.quote(name)}-\d}
        end
      end

      def install!
        spin = CLI::UI::SpinGroup.new
        spin.add("Installing #{name} gem...") do |spinner|
          ctx.system("gem install #{name}")
          spinner.update_title("Installed #{name} gem")
        end
        spin.wait
      end
    end
  end
end
