require 'fileutils'

module ShopifyCli
  module Helpers
    module ProcessSupervision
      DebriefableError = Class.new(StandardError)

      class << self
        def start(identifier, args)
          fork do
            pid_file = PidFile.new(identifier, pid: Process.pid)
            PidFile.write(pid_file)

            STDOUT.reopen(pid_file.log_path, "w")
            STDERR.reopen(pid_file.log_path, "w")
            STDIN.reopen("/dev/null", "r")
            Process.setsid

            exec(*args)
          end
          sleep(0.1)
        end

        def stop(identifier)
          pid_file = pid_file_for_id(identifier)
          return unless pid_file
          pid = pid_file.pid

          process_group = -pid
          stop_pid(process_group)
        rescue Errno::ESRCH
          begin
            # The process group does not exist, try the pid itself,
            stop_pid(pid)
          rescue Errno::ESRCH
            # Race condition, process died in the middle
          end
        end

        def running?(identifier)
          pid_file = PidFile.for(identifier)
          return false unless pid_file
          pid_alive?(pid_file.pid)
        end

        private

        def stop_pid(pid)
          Process.kill('TERM', pid)
          50.times do
            sleep 0.1
            break unless pid_alive?(pid)
          end
          Process.kill('KILL', pid) if pid_alive?(pid)
        end

        def pid_alive?(pid)
          Process.kill(0, pid) # signal 0 checks if pid is alive
          true
        rescue Errno::ESRCH
          false
        rescue Errno::EPERM
          true
        end

        def pid_file_for_id(identifier)
          pid_file = PidFile.for(identifier)
          return nil unless pid_file
          return pid_file if pid_alive?(pid_file.pid)

          pid_file.unlink # clean up if pidfile specifies dead pid
          nil
        rescue Errno::ENOENT
          nil
        end
      end
    end
  end
end
