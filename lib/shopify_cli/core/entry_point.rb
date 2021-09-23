require "shopify_cli"

module ShopifyCLI
  module Core
    module EntryPoint
      class << self
        def call(args, ctx = Context.new)
          if ctx.development?
            ctx.warn(
              ctx.message("core.warning.development_version", File.join(ShopifyCLI::ROOT, "bin", ShopifyCLI::TOOL_NAME))
            )
          elsif !ctx.testing?
            new_version = ctx.new_version
            ctx.warn(ctx.message("core.warning.new_version", ShopifyCLI::VERSION, new_version)) unless new_version.nil?
          end

          ProjectType.load_all

          task_registry = ShopifyCLI::Tasks::Registry

          command, command_name, args = ShopifyCLI::Resolver.call(args)
          executor = ShopifyCLI::Core::Executor.new(ctx, task_registry, log_file: ShopifyCLI.log_file)
          ShopifyCLI::Core::Monorail.log(command_name, args) do
            executor.call(command, command_name, args)
          end
        end
      end
    end
  end
end
