require "shopify_cli"

module ShopifyCLI
  module Core
    module EntryPoint
      class << self
        def call(args, ctx = Context.new)
          show_warnings(ctx, args.join(" "))

          ProjectType.load_all

          task_registry = ShopifyCLI::Tasks::Registry

          command, command_name, args = ShopifyCLI::Resolver.call(args)
          executor = ShopifyCLI::Core::Executor.new(ctx, task_registry, log_file: ShopifyCLI.log_file)
          ShopifyCLI::Core::Monorail.log(command_name, args) do
            executor.call(command, command_name, args)
          end
        end

        def show_warnings(ctx, args)
          # Only instruct the user to update the CLI, or warn them that they're
          # using CLI2 not CLI3, if they're running CLI2 directly. Otherwise the
          # warnings will be confusing and/or incorrect.
          return if Environment.run_as_subprocess?

          show_sunset_warning(ctx, args)

          if ctx.development? && !ctx.testing?
            ctx.warn(
              ctx.message(
                "core.warning.development_version",
                File.join(ShopifyCLI::ROOT, "bin", ShopifyCLI::TOOL_NAME)
              )
            )
            # because `!ctx.new_version.nil?` will change the config by calling ::Config.set
            # it's important to keep the checks in this order so that we don't trigger it while testing
            # since changing the config will throw errors
          elsif !ctx.testing? && !ctx.new_version.nil?
            ctx.warn(ctx.message("core.warning.new_version", ShopifyCLI::VERSION, ctx.new_version))
          end

          if ShopifyCLI::Core::CliVersion.using_3_0?
            ctx.warn(ctx.message("core.warning.in_3_0_directory"))
          end
        end

        def show_sunset_warning(ctx, args)
          return if ctx.testing?

          if args.start_with?("app create") || args.start_with?("app extension create")
            ctx.warn(ctx.message("core.warning.sunset_create_app"))
          elsif args.start_with?("app")
            ctx.warn(ctx.message("core.warning.sunset_app"))
          elsif args.start_with?("theme")
            ctx.warn(ctx.message("core.warning.sunset_theme"))
          else
            ctx.warn(ctx.message("core.warning.sunset"))
          end
        end
      end
    end
  end
end
