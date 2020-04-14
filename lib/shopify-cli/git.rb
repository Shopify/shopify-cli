module ShopifyCli
  class Git
    GIT_SHA_PATTERN = %r{^[a-f0-9]{40}$}
    PROJECT_EXISTS = "Project directory already exists. Please create a project with a new name."

    def initialize(ctx)
      @ctx = ctx
    end

    def branches
      output, status = @ctx.capture2e('git', 'branch', '--list', '--format=%(refname:short)')
      @ctx.abort("Could not find any git branches") unless status.success?

      branches = if output == ''
        ['master']
      else
        output.split("\n")
      end

      branches
    end

    def init
      output, status = @ctx.capture2e('git', 'status')

      unless status.success?
        msg = "Git repo is not initiated. Please run `git init` and make at least one commit."
        @ctx.abort(msg)
      end

      if output.include?('No commits yet')
        @ctx.abort("No git commits have been made. Please make at least one commit.")
      end
    end

    class << self
      def exec(*args, dir: Dir.pwd, default: nil, ctx: Context.new)
        args = %w(git) + args
        out, _, stat = ctx.capture3(*args, chdir: dir)
        return default unless stat.success?
        out.chomp
      end

      def sha(dir: Dir.pwd, ctx: Context.new)
        rev_parse('HEAD', dir: dir, ctx: ctx)
      end

      def clone(repository, dest, ctx: Context.new)
        if Dir.exist?(dest)
          ctx.abort(PROJECT_EXISTS)
        else
          CLI::UI::Frame.open("Cloning into #{dest}...") do
            clone_progress('clone', '--single-branch', repository, dest, ctx: ctx)
          end
          ctx.done("Cloned app in #{dest}")
        end
      end

      private

      def rev_parse(*args, dir: nil, ctx: Context.new)
        exec('rev-parse', *args, dir: dir, ctx: ctx)
      end

      def clone_progress(*git_command, ctx:)
        CLI::UI::Progress.progress do |bar|
          msg = []
          success = ctx.system('git', *git_command, '--progress') do |_out, err|
            if err.strip.start_with?('Receiving objects:')
              percent = (err.match(/Receiving objects:\s+(\d+)/)[1].to_f / 100).round(2)
              bar.tick(set_percent: percent)
              next
            end
            msg << err
          end.success?
          unless success
            ctx.abort(msg.join("\n"))
          end
          bar.tick(set_percent: 1.0)
          true
        end
      end
    end
  end
end
