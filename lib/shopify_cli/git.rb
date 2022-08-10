module ShopifyCLI
  ##
  # ShopifyCLI::Git wraps git functionality to make it easier to integrate will
  # git.
  class Git
    class << self
      # Check if Git exists in the environment
      def exists?(ctx)
        _output, status = ctx.capture2e("git", "version")
        status.success?
      rescue Errno::ENOENT # git is not installed
        false
      end

      # Check if the current working directory is a Git repository
      def available?(ctx)
        _output, status = ctx.capture2e("git", "status")
        status.success?
      rescue Errno::ENOENT # git is not installed
        false
      end

      ##
      # will return the current sha of the cli repo
      #
      # #### Parameters
      #
      # * `dir` - the directory of the git repo. This defaults to the cli repo
      # * `ctx` - the current running context of your command
      #
      # #### Returns
      #
      # * `sha_string` - string of the sha of the most recent commit to the repo
      #
      # #### Example
      #
      #   ShopifyCLI::Git.sha
      #
      # Some environments don't have git in PATH and this prevents
      # the execution from raising an error
      # https://app.bugsnag.com/shopify/shopify-cli/errors/615dd36365ce57000889d4c5
      def sha(dir: Dir.pwd, ctx: Context.new)
        if available?(ctx)
          rev_parse("HEAD", dir: dir, ctx: ctx)
        end
      end

      ##
      # returns array with components of git clone command
      #
      # #### Parameters
      #
      # * `repo` - repo url without branch name
      # * `dest` - a filepath to where the repo should be cloned to
      # * `branch` - branch name when cloning
      #
      # #### Returns
      #
      # * array of strings
      #
      # #### Example
      #
      #   ["clone", "--single-branch", "--branch", "test-branch", "test-app"]
      #
      def git_clone_command(repo, dest, branch)
        if branch
          ["clone", "--single-branch", "--branch", branch, repo, dest]
        else
          ["clone", "--single-branch", repo, dest]
        end
      end

      ##
      # calls git to clone a new repo into a supplied destination,
      # it will also call a supplied block with the percentage of clone completion
      #
      # #### Parameters
      #
      # * `repo_with_branch` - a git url for git to clone the repo from
      # * `dest` - a filepath to where the repo should be cloned to
      # * `ctx` - the current running context of your command, defaults to a new context.
      #
      # #### Returns
      #
      # * `sha_string` - string of the sha of the most recent commit to the repo
      #
      # #### Example
      #
      #   ShopifyCLI::Git.raw_clone('git@github.com:shopify/test.git', 'test-app')
      #
      def raw_clone(repo_with_branch, dest, ctx: Context.new)
        if Dir.exist?(dest) && !Dir.empty?(dest)
          ctx.abort(ctx.message("core.git.error.directory_exists"))
        else
          msg = []
          # require at usage point to not slow down CLI startup
          # https://github.com/Shopify/shopify-cli/pull/698#discussion_r444342445
          require "open3"

          repo, branch = repo_with_branch.split("#")
          git_cmd = git_clone_command(repo, dest, branch)

          success = Open3.popen3("git", *git_cmd, "--progress") do |_stdin, _stdout, stderr, thread|
            msg = clone_progress(stderr, bar: nil)

            thread.value
          end.success?

          ctx.abort((msg.join("\n"))) unless success
        end
      end

      ##
      # calls git to clone a new repo into a supplied destination,
      # it will also output progress of the cloning process into a new progress bar
      #
      # #### Parameters
      #
      # * `repo_with_branch` - a git url for git to clone the repo from
      # * `dest` - a filepath to where the repo should be cloned to
      # * `ctx` - the current running context of your command, defaults to a new context.
      #
      # #### Returns
      #
      # * `sha_string` - string of the sha of the most recent commit to the repo
      #
      # #### Example
      #
      #   ShopifyCLI::Git.clone('git@github.com:shopify/test.git', 'test-app')
      #
      def clone(repo_with_branch, dest, ctx: Context.new)
        if Dir.exist?(dest) && !Dir.empty?(dest)
          ctx.abort(ctx.message("core.git.error.directory_exists"))
        else
          msg = []
          # require at usage point to not slow down CLI startup
          # https://github.com/Shopify/shopify-cli/pull/698#discussion_r444342445
          require "open3"

          repo, branch = repo_with_branch.split("#")
          git_cmd = git_clone_command(repo, dest, branch)

          success_message = ctx.message("core.git.cloned", dest)

          CLI::UI::Frame.open(ctx.message("core.git.cloning", repo, dest), success_text: success_message) do
            CLI::UI::Progress.progress do |bar|
              success = Open3.popen3("git", *git_cmd, "--progress") do |_stdin, _stdout, stderr, thread|
                msg = clone_progress(stderr, bar: bar)

                thread.value
              end.success?

              ctx.abort((msg.join("\n"))) unless success
              bar.tick(set_percent: 1.0)
            end
          end
        end
      end

      ##
      # will fetch the repos list of branches.
      #
      # #### Parameters
      #
      # * `ctx` - the current running context of your command, defaults to a new context.
      #
      # #### Returns
      #
      # * `branches` - [String] an array of strings that are branch names
      #
      # #### Example
      #
      #   branches = ShopifyCLI::Git.branches(@ctx)
      #
      def branches(ctx)
        output, status = ctx.capture2e("git", "branch", "--list", "--format=%(refname:short)")
        ctx.abort(ctx.message("core.git.error.no_branches_found")) unless status.success?

        branches = if output == ""
          ["master"]
        else
          output.split("\n")
        end

        branches
      end

      ##
      # Run git three-way file merge (it doesn't require an initialized git repository)
      #
      # #### Parameters
      #
      # * `current_file  - string path of the current file
      # * `base_file`    - string path of the base file
      # * `other_file`   - string path of the other file
      # * `opts`         - list of "git merge-file" options. Valid values:
      #                    - "-q"       - do not warn about conflicts
      #                    - "--diff3"  - show conflicts
      #                    - "--ours"   - resolve conflicts favoring lines from `current_file`
      #                    - "--theirs" - resolve conflicts favoring lines from `other_file`
      #                    - "--union"  - resolve conflicts favoring lines from both files
      #                    - "-p"       - send results to standard output instead of
      #                                 overwriting the `current_file`
      # * `ctx`          - the current running context of your command, defaults to a new context
      #
      # #### Returns
      #
      # * standard output from git
      #
      # #### Example
      #
      #   output = ShopifyCLI::Git.merge_file(current_file, base_file, other_file, opts, ctx: ctx)
      #
      def merge_file(current_file, base_file, other_file, opts = [], ctx: Context.new)
        output, status = ctx.capture2e("git", "merge-file", current_file, base_file, other_file, *opts)

        unless status.success?
          ctx.abort(ctx.message("core.git.error.merge_failed"))
        end

        output
      end

      ##
      # will initialize a new repo in the current directory. This will output
      # if it was successful or not.
      #
      # #### Parameters
      #
      # * `ctx` - the current running context of your command, defaults to a new context.
      #
      # #### Example
      #
      #   ShopifyCLI::Git.init(@ctx)
      #
      def init(ctx)
        output, status = ctx.capture2e("git", "status")

        unless status.success?
          ctx.abort(ctx.message("core.git.error.repo_not_initiated"))
        end

        if output.include?("No commits yet")
          ctx.abort(ctx.message("core.git.error.no_commits_made"))
        end
      end

      def sparse_checkout(repo, set, branch, ctx)
        _, status = ctx.capture2e("git init")
        unless status.success?
          ctx.abort(ctx.message("core.git.error.repo_not_initiated"))
        end

        _, status = ctx.capture2e("git remote add -f origin #{repo}")
        unless status.success?
          ctx.abort(ctx.message("core.git.error.remote_not_added"))
        end

        _, status = ctx.capture2e("git config core.sparsecheckout true")
        unless status.success?
          ctx.abort(ctx.message("core.git.error.sparse_checkout_not_enabled"))
        end

        _, status = ctx.capture2e("git sparse-checkout set #{set}")
        unless status.success?
          ctx.abort(ctx.message("core.git.error.sparse_checkout_not_set"))
        end

        resp, status = ctx.capture2e("git pull origin #{branch}")
        unless status.success?
          if resp.include?("fatal: couldn't find remote ref")
            ctx.abort(ctx.message("core.git.error.pull_failed_bad_branch", branch))
          end
          ctx.abort(ctx.message("core.git.error.pull_failed"))
        end
      end

      ##
      # handles showing the progress of the git clone command.
      # if block given, assumes passing percent to block, otherwise
      # increments bar for progress bar
      #
      # #### Parameters
      #
      # * `stderr` - Open3.popen3 output stream
      # * `bar` - progress bar object to set percent
      #
      def clone_progress(stderr, bar: nil)
        msg = []

        while (line = stderr.gets)
          msg << line.chomp
          next unless line.strip.start_with?("Receiving objects:")
          percent = (line.match(/Receiving objects:\s+(\d+)/)[1].to_f / 100).round(2)

          if block_given?
            yield percent
          elsif !bar.nil?
            bar.tick(set_percent: percent)
          end
        end

        msg
      end

      private

      def exec(*args, dir: Dir.pwd, default: nil, ctx: Context.new)
        args = %w(git) + ["--git-dir", File.join(dir, ".git")] + args
        out, _, stat = ctx.capture3(*args)
        return default unless stat.success?
        out.chomp
      end

      def rev_parse(*args, dir: nil, ctx: Context.new)
        exec("rev-parse", *args, dir: dir, ctx: ctx)
      end
    end
  end
end
