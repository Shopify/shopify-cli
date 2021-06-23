require "shopify_cli"

module ShopifyCli
  module Core
    module EntryPoint
      class << self
        def call(args, ctx = Context.new)
          if ctx.development?
            ctx.warn(
              ctx.message("core.warning.development_version", File.join(ShopifyCli::ROOT, "bin", ShopifyCli::TOOL_NAME))
            )
          elsif !ctx.testing?
            new_version = ctx.new_version
            ctx.warn(ctx.message("core.warning.new_version", ShopifyCli::VERSION, new_version)) unless new_version.nil?
          end

          ProjectType.load_all

          task_registry = ShopifyCli::Tasks::Registry

          command, command_name, args = ShopifyCli::Resolver.call(args)
          executor = ShopifyCli::Core::Executor.new(ctx, task_registry, log_file: ShopifyCli.log_file)
          ShopifyCli::Core::Monorail.log(command_name, args) do
            executor.call(command, command_name, args)
          end
        end
      end
    end
  end
end
