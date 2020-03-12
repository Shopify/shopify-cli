module ShopifyCli
  module Helpers
    module Git
      class << self
        GIT_SHA_PATTERN = %r{^[a-f0-9]{40}$}
        PROJECT_EXISTS = "{{red:{{x}} Project directory already exists. \
        Please create a project with a new name.}}"

        def exec(*args, dir: Dir.pwd, default: nil, ctx: Context.new)
          args = %w(git) + args
          out, _, stat = ctx.capture3(*args, chdir: dir)
          return default unless stat.success?
          out.chomp
        end

        def sha(dir: Dir.pwd, ctx: Context.new)
          rev_parse('HEAD', dir: dir, ctx: ctx)
        end

        def clone(repository, dest)
          if Dir.exist?(dest)
            abort(CLI::UI.fmt(PROJECT_EXISTS))
          else
            CLI::UI::Frame.open("Cloning into #{dest}...") do
              clone_progress('clone', '--single-branch', repository, dest)
            end
            puts CLI::UI.fmt("{{v}} Cloned app in #{dest}")
          end
        end

        private

        def rev_parse(*args, dir: nil, ctx: Context.new)
          exec('rev-parse', *args, dir: dir, ctx: ctx)
        end

        def clone_progress(*git_command)
          CLI::UI::Progress.progress do |bar|
            msg = []
            success = CLI::Kit::System.system('git', *git_command, '--progress') do |_out, err|
              if err.strip.start_with?('Receiving objects:')
                percent = (err.match(/Receiving objects:\s+(\d+)/)[1].to_f / 100).round(2)
                bar.tick(set_percent: percent)
                next
              end
              msg << err
            end.success?
            unless success
              raise(ShopifyCli::Abort, msg.join("\n"))
            end
            bar.tick(set_percent: 1.0)
            true
          end
        end
      end
    end
  end
end
