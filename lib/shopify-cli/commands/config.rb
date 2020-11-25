require 'shopify_cli'

module ShopifyCli
  module Commands
    class Config < ShopifyCli::Command
      hidden_feature(feature_set: :debug)

      subcommand :Feature, 'feature'
      subcommand :Analytics, 'analytics'
      subcommand :TipOfTheDay, 'tipoftheday'

      def call(*)
        @ctx.puts(self.class.help)
      end

      def self.help
        ShopifyCli::Context.message('core.config.help', ShopifyCli::TOOL_NAME)
      end

      class Feature < ShopifyCli::SubCommand
        def self.help
          ShopifyCli::Context.message('core.config.feature.help', ShopifyCli::TOOL_NAME)
        end

        options do |parser, flags|
          parser.on('--enable') { flags[:action] = 'enable' }
          parser.on('--disable') { flags[:action] = 'disable' }
          parser.on('--status') { flags[:action] = 'status' }
        end

        def call(args, _name)
          feature_name = args.shift
          return @ctx.puts(@ctx.message('core.config.help', ShopifyCli::TOOL_NAME)) if feature_name.nil?
          is_enabled = ShopifyCli::Feature.enabled?(feature_name)
          if options.flags[:action] == 'disable' && is_enabled
            ShopifyCli::Feature.disable(feature_name)
            @ctx.puts(@ctx.message('core.config.feature.disabled', feature_name))
          elsif options.flags[:action] == 'enable' && !is_enabled
            ShopifyCli::Feature.enable(feature_name)
            @ctx.puts(@ctx.message('core.config.feature.enabled', feature_name))
          elsif is_enabled
            @ctx.puts(@ctx.message('core.config.feature.is_enabled', feature_name))
          else
            @ctx.puts(@ctx.message('core.config.feature.is_disabled', feature_name))
          end
        end
      end

      class Analytics < ShopifyCli::SubCommand
        def self.help
          ShopifyCli::Context.message('core.config.analytics.help', ShopifyCli::TOOL_NAME)
        end

        options do |parser, flags|
          parser.on('--enable') { flags[:action] = 'enable' }
          parser.on('--disable') { flags[:action] = 'disable' }
          parser.on('--status') { flags[:action] = 'status' }
        end

        def call(_args, _name)
          is_enabled = ShopifyCli::Config.get_bool('analytics', 'enabled')
          if options.flags[:action] == 'disable' && is_enabled
            ShopifyCli::Config.set('analytics', 'enabled', false)
            @ctx.puts(@ctx.message('core.config.analytics.disabled'))
          elsif options.flags[:action] == 'enable' && !is_enabled
            ShopifyCli::Config.set('analytics', 'enabled', true)
            @ctx.puts(@ctx.message('core.config.analytics.enabled'))
          elsif is_enabled
            @ctx.puts(@ctx.message('core.config.analytics.is_enabled'))
          else
            @ctx.puts(@ctx.message('core.config.analytics.is_disabled'))
          end
        end
      end

      class TipOfTheDay < ShopifyCli::SubCommand
        def self.help
          ShopifyCli::Context.message('core.config.tipoftheday.help', ShopifyCli::TOOL_NAME)
        end

        options do |parser, flags|
          parser.on('--enable') { flags[:action] = 'enable' }
          parser.on('--disable') { flags[:action] = 'disable' }
          parser.on('--status') { flags[:action] = 'status' }
        end

        def call(_args, _name)
          is_enabled = ShopifyCli::Config.get_bool('tipoftheday', 'enabled')
          if options.flags[:action] == 'disable' && is_enabled
            ShopifyCli::Config.set('tipoftheday', 'enabled', false)
            @ctx.puts(@ctx.message('core.config.tipoftheday.disabled'))
          elsif options.flags[:action] == 'enable' && !is_enabled
            ShopifyCli::Config.set('tipoftheday', 'enabled', true)
            @ctx.puts(@ctx.message('core.config.tipoftheday.enabled'))
          elsif is_enabled
            @ctx.puts(@ctx.message('core.config.tipoftheday.is_enabled'))
          else
            @ctx.puts(@ctx.message('core.config.tipoftheday.is_disabled'))
          end
        end
      end
    end
  end
end
