require 'fileutils'

module ShopifyCli
  class ProcessSupervision
    DebriefableError = Class.new(StandardError)
    RUN_DIR = File.join(ShopifyCli::TEMP_DIR, 'sv')

    attr_reader :identifier, :pid, :time, :pid_path, :log_path

    class << self
      def for_ident(identifier)
        pid, time = File.read(File.join(RUN_DIR, "#{identifier}.pid")).split(':')
        new(identifier, pid: Integer(pid), time: time)
      rescue Errno::ENOENT
        nil
      end

      def start(identifier, args)
        return for_ident(identifier) if running?(identifier)
        fork do
          pid_file = new(identifier, pid: Process.pid)
          pid_file.write
          STDOUT.reopen(pid_file.log_path, "w")
          STDERR.reopen(pid_file.log_path, "w")
          STDIN.reopen("/dev/null", "r")
          Process.setsid
          exec(*args)
        end
        sleep(0.1)
        for_ident(identifier)
      end

      def stop(identifier)
        process = for_ident(identifier)
        return false unless process
        process.stop
      end

      def running?(identifier)
        process = for_ident(identifier)
        return false unless process
        process.alive?
      end
    end

    def initialize(identifier, pid:, time: Time.now.strftime('%s'))
      @identifier = identifier
      @pid = pid
      @time = time
      @pid_path = File.join(RUN_DIR, "#{identifier}.pid")
      @log_path = File.join(RUN_DIR, "#{identifier}.log")
    end

    def stop
      unlink
      kill_proc
      true
    rescue
      false
    end

    def alive?
      stat(pid)
    end

    def unlink
      File.unlink(pid_path)
      File.unlink(log_path)
      nil
    rescue Errno::ENOENT
      nil
    end

    def write
      FileUtils.mkdir_p(File.dirname(pid_path))
      File.write(pid_path, "#{pid}:#{time}")
    end

    private

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
