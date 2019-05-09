require 'fileutils'

module ShopifyCli
  module Helpers
    module ProcessSupervision
      DebriefableError = Class.new(StandardError)

      class << self
        def start(args)
          pid = fork do
            STDIN.reopen("/dev/null", "r")
            Process.setsid

            exec(*args)
          end
          pid
        end

        def stop(pid)
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

        def running?(pid)
          pid_alive?(pid)
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
      end
    end
  end
end
