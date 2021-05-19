require "fileutils"

module ShopifyCLI
  ##
  # ProcessSupervision wraps a running process spawned by `exec` and keeps track
  # if its `pid` and keeps a log file for it as well
  class ProcessSupervision
    # a string or a symbol to identify this process by
    attr_reader :identifier
    # process ID for the running process
    attr_accessor :pid
    # starttime of the process
    attr_reader :time
    # filepath to the pidfile for this process
    attr_reader :pid_path
    # filepath to the logfile for this process
    attr_reader :log_path

    class << self
      def run_dir
        # is the directory where the pid and logfile are kept
        File.join(ShopifyCLI.cache_dir, "sv")
      end

      ##
      # Will find and create a new instance of ProcessSupervision for a running process
      # if it is currently running. It will return nil if the process is not running.
      #
      # #### Parameters
      #
      # * `identifier` - a string or a symbol that a process was started with
      #
      # #### Returns
      #
      # * `process` - ProcessSupervision instance if the process is running this
      #   will be nil if the process is not running.
      #
      def for_ident(identifier)
        pid, time = File.read(File.join(ShopifyCLI::ProcessSupervision.run_dir, "#{identifier}.pid")).split(":")
        new(identifier, pid: Integer(pid), time: time)
      rescue Errno::ENOENT
        nil
      end

      ##
      # will fork and spawn a new process that is separate from the current process.
      # This process will keep running beyond the command running so be careful!
      #
      # #### Parameters
      #
      # * `identifier` - a string or symbol to identify the new process by.
      # * `args` - a command to run, either a string or array of strings
      # * `force_spawn` - whether we want the child process to be a spawn and not a fork, so it is terminated along with
      #                   the parent
      #
      # #### Returns
      #
      # * `process` - ProcessSupervision instance if the process is running, this
      #   will be nil if the process did not start.
      #
      def start(identifier, args, force_spawn: false)
        return for_ident(identifier) if running?(identifier)

        # Some systems don't support forking process without extra gems, so we resort to spawning a new child process -
        # that means that it dies along with the original process if it is interrupted. If possible, we fork the process
        # so that it doesn't have to be restarted on every run.
        if Process.respond_to?(:fork) && !force_spawn
          fork do
            pid_file = new(identifier, pid: Process.pid)
            pid_file.write
            STDOUT.reopen(pid_file.log_path, "w")
            STDERR.reopen(pid_file.log_path, "w")
            STDIN.reopen("/dev/null", "r")
            Process.setsid
            exec(*args)
          end
        else
          pid_file = new(identifier)

          # Make sure the file exists and is empty, otherwise Windows fails
          File.open(pid_file.log_path, "w") {}
          pid = Process.spawn(
            *args,
            out: pid_file.log_path,
            err: pid_file.log_path,
            in: Context.new.windows? ? "nul" : "/dev/null",
          )
          pid_file.pid = pid
          pid_file.write

          Process.detach(pid)
        end

        sleep(0.1)
        for_ident(identifier)
      end

      ##
      # will attempt to shutdown a running process
      #
      # #### Parameters
      #
      # * `identifier` - a string or symbol to identify the new process by.
      #
      # #### Returns
      #
      # * `stopped` - [true, false]
      #
      def stop(identifier)
        process = for_ident(identifier)
        return false unless process
        process.stop
      end

      ##
      # will help identify if your process is still running in the background.
      #
      # #### Parameters
      #
      # * `identifier` - a string or symbol to identify the new process by.
      #
      # #### Returns
      #
      # * `running` - [true, false]
      #
      def running?(identifier)
        process = for_ident(identifier)
        return false unless process
        process.alive?
      end
    end

    def initialize(identifier, pid: nil, time: Time.now.strftime("%s")) # :nodoc:
      @identifier = identifier
      @pid = pid
      @time = time
      FileUtils.mkdir_p(ShopifyCLI::ProcessSupervision.run_dir)
      @pid_path = File.join(ShopifyCLI::ProcessSupervision.run_dir, "#{identifier}.pid")
      @log_path = File.join(ShopifyCLI::ProcessSupervision.run_dir, "#{identifier}.log")
    end

    ##
    # will attempt to shutdown a running process
    #
    # #### Parameters
    #
    # * `ctx` - the context of this command
    #
    # #### Returns
    #
    # * `stopped` - [true, false]
    #
    def stop
      kill_proc
      unlink
      true
    rescue
      false
    end

    ##
    # will help identify if your process is still running in the background.
    #
    # #### Returns
    #
    # * `alive` - [true, false]
    #
    def alive?
      stat(pid)
    end

    ##
    # persists the pidfile
    #
    def write
      FileUtils.mkdir_p(File.dirname(pid_path))
      File.write(pid_path, "#{pid}:#{time}")
    end

    private

    def unlink
      File.unlink(pid_path)
      File.unlink(log_path)
      nil
    rescue Errno::ENOENT
      nil
    end

    def kill_proc
      if Context.new.windows?
        kill(pid)
      else
        kill(-pid) # process group
      end
    rescue Errno::ESRCH
      begin
        kill(pid)
      rescue Errno::ESRCH # The process group does not exist, try the pid itself
        # Race condition, process died in the middle
      end
    end

    def kill(id)
      ctx = Context.new

      # Windows does not handle SIGTERM, go straight to SIGKILL
      unless ctx.windows?
        Process.kill("TERM", id)
        50.times do
          sleep(0.1)
          break unless stat(id)
        end
      end
      Process.kill("KILL", id) if stat(id)
      sleep(0.1) if ctx.windows? # Give Windows a second to actually close the process
    end

    def stat(id)
      Process.kill(0, id) # signal 0 checks if pid is alive
      true
    rescue Errno::EPERM
      true
    rescue Errno::ESRCH
      false
    end
  end
end
