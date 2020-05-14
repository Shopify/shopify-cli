require 'shopify_cli'

module ShopifyCli
  module Core
    module Update
      FETCH_HEAD = File.expand_path('.git/FETCH_HEAD', ShopifyCli::ROOT)

      class << self
        def auto_update
          return if Context.new.testing?
          prompt_for_updates
          return unless ShopifyCli::Config.get_bool('autoupdate', 'enabled')

          # don't update more than once per hour.
          file = begin
                  File.mtime(FETCH_HEAD)
                 rescue Errno::ENOENT
                   Time.at(0)
                end
          age = Time.now - file
          return unless age > 3600

          check_now(restart_command_after_update: true)
        end

        def check_now(restart_command_after_update: raise, ctx: ShopifyCli::Context.new)
          if Context.new.development?
            if restart_command_after_update
              return # just skip
            else
              err(Context.message('core.update.error.development_version', ShopifyCli::TOOL_NAME))
              raise(ShopifyCli::AbortSilent)
            end
          end

          if File.exist?(File.expand_path('.git/HEAD.lock', ShopifyCli::ROOT))
            err(Context.message('core.update.error.git_head_locked', ShopifyCli::ROOT, ShopifyCli::TOOL_NAME))
            raise(ShopifyCli::AbortSilent)
          end

          if File.exist?(File.expand_path(".git/refs/heads/master.lock", ShopifyCli::ROOT))
            err(Context.message('core.update.error.git_master_locked', ShopifyCli::ROOT, ShopifyCli::TOOL_NAME))
            raise(ShopifyCli::AbortSilent)
          end

          _, stat = ctx.capture2e('git', '-C', ShopifyCli::ROOT, 'fetch', 'origin', 'master')
          unless stat.success?
            ctx.abort('failed!')
          end

          commands = [
            ['reset', '.'],
            ['checkout', '.'],
            ['checkout', '-f', '-B', 'master'],
            ['reset', '--hard', 'FETCH_HEAD'],
          ]
          Kernel.print(Context.message('core.update.updating'))
          commands.each do |args|
            _, stat = ctx.capture2e('git', '-C', ShopifyCli::ROOT, *args)
            ctx.abort(Context.message('core.update.error.git_command_failure', args.join(' '))) unless stat.success?
          end

          ctx.puts(Context.message('core.update.updated'))

          if restart_command_after_update
            ENV.replace($original_env)
            opts = begin
                    { 9 => IO.new(9) }
                   rescue Errno::EBADF
                     {}
                  end

            exec($PROGRAM_NAME, *ARGV, opts)
          end
        end

        def prompt_for_updates
          return if ShopifyCli::Config.get_section('autoupdate').key?('enabled')
          opt = CLI::UI::Prompt.confirm(Context.message('core.update.auto_update_prompt'))
          ShopifyCli::Config.set('autoupdate', 'enabled', opt)
          auto_update
        end

        def record_last_update_time
          @last_update_time = last_update_time
        end

        def updated_since_last_recorded?
          @last_update_time != last_update_time
        end

        def last_update_time
          File.mtime(FETCH_HEAD)
        rescue Errno::ENOENT
          Time.now
        end

        def err(msg, newline: true)
          method = newline ? :puts : :print
          STDERR.send(method, CLI::UI.fmt("{{bold:{{red:#{msg}}}}}"))
        end
      end
    end
  end
end
