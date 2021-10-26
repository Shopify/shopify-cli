require "open3"
require_relative "../../utilities/utilities"

module Process
  class ProcessError < StandardError
    attr_reader :exit_status, :stderr
    def initialize(exit_status:, stderr:)
      @exit_status = exit_status
      @stderr = stderr
      super
    end

    def to_s
      stderr
    end
  end

  def self.run(*args, cwd: nil)
    cwd ||= Dir.pwd
    _, err, stat = Open3.capture3(*args, chdir: cwd)
    raise ProcessError.new(exit_status: stat.exitstatus, stderr: err) unless stat.success?
  end

  def self.shopify_executable_path
    File.expand_path("../../bin/shopify", __dir__)
  end
end
