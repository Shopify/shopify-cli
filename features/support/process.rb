require "open3"

module Process
  ENV_VARIABLES = { "SHOPIFY_CLI_ACCEPTANCE_TEST" => "1" }
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

  def self.run_shopify(*args, cwd: nil)
    args = [shopify_executable_path] + args
    cwd ||= Dir.pwd
    _, err, stat = Open3.capture3(ENV_VARIABLES, *args, chdir: cwd)
    raise ProcessError.new(exit_status: stat.exitstatus, stderr: err) unless stat.success?
  end

  def self.run(*args, cwd: nil)
    cwd ||= Dir.pwd
    _, err, stat = Open3.capture3(ENV_VARIABLES, *args, chdir: cwd)
    raise ProcessError.new(exit_status: stat.exitstatus, stderr: err) unless stat.success?
  end

  def self.capture_shopify(*args, cwd: nil)
    args = [shopify_executable_path] + args
    cwd ||= Dir.pwd

    out, err, stat = Open3.capture3(ENV_VARIABLES, *args, chdir: cwd)
    raise ProcessError.new(exit_status: stat.exitstatus, stderr: err) unless stat.success?
    out
  end

  def self.shopify_executable_path
    File.expand_path("../../bin/shopify", __dir__)
  end
end
