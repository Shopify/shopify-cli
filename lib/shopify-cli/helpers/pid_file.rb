require 'fileutils'

module ShopifyCli
  module Helpers
    class PidFile
      class << self
        RUN_DIR = File.join(ShopifyCli::TEMP_DIR, 'sv')

        def for(identifier)
          pid, time = File.read(pid_path_for(identifier)).split(':')
          new(identifier, pid: Integer(pid), time: time)
        rescue Errno::ENOENT
          nil
        end

        def write(pid_file)
          FileUtils.mkdir_p(File.dirname(pid_file.pid_path))
          File.write(pid_file.pid_path, "#{pid_file.pid}:#{pid_file.time}")
        end

        def pid_path_for(identifier)
          File.join(RUN_DIR, "#{identifier}.pid")
        end

        def log_path_for(identifier)
          File.join(RUN_DIR, "#{identifier}.log")
        end
      end

      attr_reader :identifier, :pid, :time

      def initialize(identifier, pid:, time: Time.now.strftime('%s'))
        @identifier = identifier
        @pid = pid
        @time = time
      end

      def pid_path
        @pid_path ||= PidFile.pid_path_for(@identifier)
      end

      def log_path
        @log_path ||= PidFile.log_path_for(@identifier)
      end

      def unlink_log
        File.unlink(log_path)
        nil
      rescue Errno::ENOENT
        nil
      end

      def unlink
        File.unlink(pid_path)
        nil
      rescue Errno::ENOENT
        nil
      end
    end
  end
end
