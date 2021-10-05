# frozen_string_literal: true
require "shopify_cli"

module Rails
  class Command
    class Generate < ShopifyCLI::SubCommand
      prerequisite_task ensure_project_type: :rails

      autoload :Webhook, Project.project_filepath("commands/generate/webhook")

      WEBHOOK = "webhook"

      def call(args, _name)
        subcommand = args.shift
        case subcommand
        when WEBHOOK
          Rails::Command::Generate::Webhook.start(@ctx, args)
        else
          @ctx.puts(self.class.help)
        end
      end

      def self.help
        ShopifyCLI::Context.message("rails.generate.help", ShopifyCLI::TOOL_NAME)
      end

      def self.extended_help
        extended_help = "{{bold:Subcommands:}}\n"
        subcommand_registry.resolved_commands.sort.each do |name, klass|
          extended_help += "  {{cyan:#{name}}}: "

          if (subcmd_help = klass.help)
            extended_help += subcmd_help.gsub("\n  ", "\n    ")
          end
          extended_help += "\n"
        end
        extended_help += ShopifyCLI::Context.message("rails.generate.extended_help", ShopifyCLI::TOOL_NAME)
      end

      def self.run_generate(script, name, ctx)
        Gem.gem_path(ctx)
        stat = ctx.system(script)
        unless stat.success?
          ctx.abort(response(stat.exitstatus, name, ctx))
        end
      end

      def self.response(code, name, ctx)
        case code
        when 1
          ctx.message("rails.generate.error.generic", name)
        when 2
          ctx.message("rails.generate.error.name_exists", name)
        else
          ctx.message("rails.error.generic")
        end
      end
    end
  end
end
