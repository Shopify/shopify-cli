require 'shopify_cli'
require 'rbconfig'

module ShopifyCli
  module Commands
    class System < ShopifyCli::Command
      hidden_command

      def call(args, _name)
        show_all_details = false
        flag = args.shift
        if flag && flag != 'all'
          @ctx.puts("{{x}} {{red:unknown option '#{flag}'}}")
          @ctx.puts("\n" + self.class.help)
          return
        end

        show_all_details = true if flag == 'all'

        display_environment if show_all_details

        display_cli_constants(show_all_details)
        display_cli_ruby(show_all_details)
        display_utility_commands(show_all_details)
        display_project_commands(show_all_details)
      end

      def self.help
        <<~HELP
          Print details about the development system.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} system [all]}}

          {{cyan:all}}: displays more details about development system and environment

        HELP
      end

      private

      def display_cli_constants(show_all_details)
        cli_constants = %w(INSTALL_DIR)
        cli_constants_extra = %w(
          ROOT
          PROJECT_TYPES_DIR
          TEMP_DIR
          CONFIG_HOME
          TOOL_CONFIG_PATH
          LOG_FILE
          DEBUG_LOG_FILE
        )

        cli_constants += cli_constants_extra if show_all_details

        @ctx.puts("{{bold:Shopify App CLI}}")
        cli_constants.each do |s|
          @ctx.puts(format("  %17s = #{ShopifyCli.const_get(s.to_sym)}\n", s))
        end
      end

      def display_cli_ruby(_show_all_details)
        rbconfig_constants = %w(host RUBY_VERSION_NAME)

        @ctx.puts("\n{{bold:Ruby (via RbConfig)}}")
        @ctx.puts("  #{RbConfig.ruby}")
        rbconfig_constants.each do |s|
          @ctx.puts(format("  %-25s - RbConfig[\"#{s}\"]", RbConfig::CONFIG[s]))
        end
      end

      def display_utility_commands(_show_all_details)
        commands = %w(git curl tar unzip)

        @ctx.puts("\n{{bold:Commands}}")
        commands.each do |s|
          output, status = @ctx.capture2e('which', s)
          if status.success?
            @ctx.puts("  {{v}} #{s}, #{output}")
          else
            @ctx.puts("  {{x}} #{s}")
          end
        end
      end

      def display_ngrok
        ngrok_location = File.join(ShopifyCli::ROOT, 'ngrok')
        if File.exist?(ngrok_location)
          @ctx.puts("  {{v}} ngrok, #{ngrok_location}")
        else
          @ctx.puts("  {{x}} ngrok NOT available")
        end
      end

      def display_project_commands(_show_all_details)
        case Project.current_project_type
        when :node
          display_project('Node.js', %w(npm node yarn))
        when :rails
          display_project('Rails', %w(gem rails rake ruby))
        end
      end

      def display_project(project_type, commands)
        @ctx.puts("\n{{bold:In a {{cyan:#{project_type}}} project directory}}")
        commands.each do |s|
          output, status = @ctx.capture2e('which', s)
          if status.success?
            version_output, _ = @ctx.capture2e(s, '--version')
            version = version_output.match(/(\d+\.[^\s]+)/)[0]
            @ctx.puts("  {{v}} #{s}, #{output.strip}, version #{version.strip}")
          else
            @ctx.puts("  {{x}} #{s}")
          end
        end
        display_ngrok
        display_project_environment
      end

      def display_project_environment
        @ctx.puts("\n  {{bold:Project environment}}")
        if File.exist?('./.env')
          Project.current.env.to_h.each do |k, v|
            display_value = if v.nil? || v.strip == ''
              "not set"
            else
              k.match(/^SHOPIFY_API/) ? "********" : v
            end
            @ctx.puts(format("  %-18s = %s", k, display_value))
          end
        else
          @ctx.puts("  {{x}} .env file not present")
        end
      end

      def display_environment
        @ctx.puts("{{bold:Environment}}")
        %w(TERM SHELL PATH USING_SHOPIFY_CLI LANG).each do |k|
          @ctx.puts(format("  %-17s = %s", k, ENV[k])) unless ENV[k].nil?
        end
        @ctx.puts("")
      end
    end
  end
end
