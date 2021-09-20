require "shopify_cli"
require "rbconfig"

module ShopifyCLI
  module Commands
    class System < ShopifyCLI::Command
      hidden_feature(feature_set: :debug)

      def call(args, _name)
        show_all_details = false
        flag = args.shift
        if flag && flag != "all"
          @ctx.puts(@ctx.message("core.system.error.unknown_option", flag))
          @ctx.puts("\n" + self.class.help)
          return
        end

        show_all_details = true if flag == "all"

        display_environment if show_all_details

        display_cli_constants(show_all_details)
        display_shopify_store(show_all_details)
        display_cli_ruby(show_all_details)
        display_utility_commands(show_all_details)
        display_project_commands(show_all_details)
        display_shopify_staff_identity if show_all_details
      end

      def self.help
        ShopifyCLI::Context.message("core.system.help", ShopifyCLI::TOOL_NAME)
      end

      private

      def display_cli_constants(show_all_details)
        cli_constants = %w(ROOT)
        cli_constants_extra = %w(
          PROJECT_TYPES_DIR
          TEMP_DIR
        )
        cli_path_methods = [
          :cache_dir,
          :tool_config_path,
          :log_file,
          :debug_log_file,
        ]

        cli_constants += cli_constants_extra if show_all_details

        @ctx.puts(@ctx.message("core.system.header"))
        cli_constants.each do |s|
          @ctx.puts("  " + @ctx.message("core.system.const", s, ShopifyCLI.const_get(s.to_sym)) + "\n")
        end

        if show_all_details
          cli_path_methods.each do |m|
            @ctx.puts("  " + @ctx.message("core.system.const", m.upcase, ShopifyCLI.send(m)) + "\n")
          end
        end
      end

      def display_shopify_store(_show_all_details)
        shop = if ShopifyCLI::DB.exists?(:shop)
          ShopifyCLI::AdminAPI.get_shop_or_abort(@ctx)
        else
          @ctx.message("core.populate.error.no_shop", ShopifyCLI::TOOL_NAME)
        end

        @ctx.puts("\n" + @ctx.message("core.system.shop_header"))
        @ctx.puts("  " + shop)
      end

      def display_cli_ruby(_show_all_details)
        rbconfig_constants = %w(host RUBY_VERSION_NAME)

        @ctx.puts("\n" + @ctx.message("core.system.ruby_header", RbConfig.ruby))
        rbconfig_constants.each do |s|
          @ctx.puts("  " + @ctx.message("core.system.rb_config", RbConfig::CONFIG[s], s))
        end
      end

      def display_utility_commands(_show_all_details)
        commands = %w(git curl tar)

        @ctx.puts("\n" + @ctx.message("core.system.command_header"))
        commands.each do |s|
          cmd_path = @ctx.which(s)

          if !cmd_path.nil?
            @ctx.puts("  " + @ctx.message("core.system.command_with_path", s, cmd_path))
          else
            @ctx.puts("  " + @ctx.message("core.system.command_not_found", s))
          end
        end
      end

      def display_ngrok
        ngrok_location = File.join(ShopifyCLI.cache_dir, "ngrok#{@ctx.executable_file_extension}")
        if File.exist?(ngrok_location)
          @ctx.puts("  " + @ctx.message("core.system.ngrok_available", ngrok_location))
        else
          @ctx.puts("  " + @ctx.message("core.system.ngrok_not_available"))
        end
      end

      def display_project_commands(_show_all_details)
        case Project.current_project_type
        when :node
          display_project("Node.js", %w(npm node yarn))
        when :rails
          display_project("Rails", %w(gem rails rake ruby))
        end
      end

      def display_project(project_type, commands)
        @ctx.puts("\n" + @ctx.message("core.system.project.header", project_type))
        commands.each do |s|
          cmd_path = @ctx.which(s)
          if !cmd_path.nil?
            version_output, _ = @ctx.capture2e(s, "--version")
            version = version_output.match(/(\d+\.[^\s]+)/)[0]
            @ctx.puts("  " + @ctx.message("core.system.project.command_with_path", s, cmd_path.strip, version.strip))
          else
            @ctx.puts("  " + @ctx.message("core.system.project.command_not_found", s))
          end
        end
        display_ngrok
        display_project_environment
      end

      def display_project_environment
        @ctx.puts("\n  " + @ctx.message("core.system.project.env_header"))
        if File.exist?("./.env")
          Project.current.env.to_h.each do |k, v|
            display_value = if v.nil? || v.strip == ""
              @ctx.message("core.system.project.env_not_set")
            else
              k.match(/^SHOPIFY_API/) ? "********" : v
            end
            @ctx.puts("  " + @ctx.message("core.system.project.env", k, display_value))
          end
        else
          @ctx.puts("  " + @ctx.message("core.system.project.no_env"))
        end
      end

      def display_environment
        @ctx.puts(@ctx.message("core.system.environment_header"))
        %w(TERM SHELL PATH USING_SHOPIFY_CLI LANG).each do |k|
          @ctx.puts("  " + @ctx.message("core.system.env", k, ENV[k])) unless ENV[k].nil?
        end
        @ctx.puts("")
      end

      def display_shopify_staff_identity
        is_shopifolk = ShopifyCLI::Shopifolk.check
        if is_shopifolk
          @ctx.puts("\n" + @ctx.message("core.system.identity_header"))
          @ctx.puts("  " + @ctx.message("core.system.identity_is_shopifolk"))
        end
      end
    end
  end
end
