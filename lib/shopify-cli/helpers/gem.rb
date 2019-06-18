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
          gem = new(ctx: ctx, name: name)
          File.join(gem.gem_home, 'bin', binary)
        end
      end

      def installed?
        !!Dir.glob("#{gem_home}/gems/#{name}-*").detect do |f|
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

      def gem_home
        @gem_home ||= (ctx.getenv('GEM_HOME') || set_gem_home)
      end

      private

      def set_gem_home
        path = File.join(ctx.getenv('HOME'), '.gem', 'ruby', RUBY_VERSION)
        ctx.mkdir_p(path)
        ctx.setenv('GEM_HOME', path)
      end
    end
  end
end
