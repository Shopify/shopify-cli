# frozen_string_literal: true
require 'shopify_cli'

module ShopifyCli
  module Helpers
    module GemHelper
      class << self
        def installed?(ctx, gem_name)
          # TODO: fallback when GEM_PATH is not populated
          gem_path = ctx.getenv('GEM_PATH').tr(':', ',')
          !!Dir.glob("{#{gem_path}}/gems/#{gem_name}-*").detect do |f|
            f =~ %r{/#{Regexp.quote(gem_name)}-\d}
          end
        end

        def installed_with_bundler?(ctx, gem_name)
          stdout, _status = ctx.capture("bundle", "exec", "gem", "list", "-i", gem_name)
          stdout.strip == 'true'
        end

        def install!(ctx, gem_name)
          ctx.system("gem install #{gem_name}")
        end
      end
    end
  end
end
