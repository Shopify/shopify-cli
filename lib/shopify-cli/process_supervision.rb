require 'fileutils'

module ShopifyCli
  ##
  # ProcessSupervision wraps a running process spawned by `exec` and keeps track
  # if its `pid` and keeps a log file for it as well
  class ProcessSupervision
    # is the directory where the pid and logfile are kept
    RUN_DIR = File.join(ShopifyCli::CACHE_DIR, 'sv')

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
        pid, time = File.read(File.join(RUN_DIR, "#{identifier}.pid")).split(':')
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
      #
      # #### Returns
      #
      # * `process` - ProcessSupervision instance if the process is running, this
      #   will be nil if the process did not start.
      #
      def start(identifier, args)
        return for_ident(identifier) if running?(identifier)

        ctx = Context.new
        pid_file = new(identifier)

        # Make sure the file exists and is empty, otherwise Windows fails
        File.open(pid_file.log_path, 'w') {}
        pid = spawn(
          *args,
          out: pid_file.log_path,
          err: pid_file.log_path,
          in: ctx.windows? ? "nul" : "/dev/null",
        )
        pid_file.pid = pid
        pid_file.write

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

    def initialize(identifier, pid: nil, time: Time.now.strftime('%s')) # :nodoc:
      @identifier = identifier
      @pid = pid
      @time = time

      FileUtils.mkdir_p(RUN_DIR)
      @pid_path = File.join(RUN_DIR, "#{identifier}.pid")
      @log_path = File.join(RUN_DIR, "#{identifier}.log")
    end

    ##
    # will attempt to shutdown a running process
    #
    # #### Returns
    #
    # * `stopped` - [true, false]
    #
    def stop
      unlink
      kill_proc
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
      kill(-pid) # process group
    rescue Errno::ESRCH
      begin
        kill(pid)
      rescue Errno::ESRCH # The process group does not exist, try the pid itself
        # Race condition, process died in the middle
      end
    end

    def kill(id)
      Process.kill('TERM', id)
      50.times do
        sleep 0.1
        break unless stat(id)
      end
      Process.kill('KILL', id) if stat(id)
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
