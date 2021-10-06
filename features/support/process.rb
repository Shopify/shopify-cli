require "open3"
require_relative "../../utilities/utilities"

module Process
  ENV_VARIABLES = { "SHOPIFY_CLI_ACCEPTANCE_TEST" => "1" }
  VM_SHOPIFY_BIN_PATH = "/usr/src/app/bin/shopify"

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

  def self.exec_shopify(*args, container_id:, cwd: nil)
    Utilities::Docker.exec(
      VM_SHOPIFY_BIN_PATH, *args,
      container_id: container_id,
      cwd: cwd,
      env: ENV_VARIABLES
    )
  end

  def self.capture_shopify(*args, container_id:, cwd: nil)
    Utilities::Docker.capture(
      VM_SHOPIFY_BIN_PATH, *args,
      container_id: container_id,
      cwd: cwd,
      env: ENV_VARIABLES
    )
  end

  def self.run(*args, cwd: nil)
    cwd ||= Dir.pwd
    _, err, stat = Open3.capture3(ENV_VARIABLES, *args, chdir: cwd)
    raise ProcessError.new(exit_status: stat.exitstatus, stderr: err) unless stat.success?
  end

  def self.shopify_executable_path
    File.expand_path("../../bin/shopify", __dir__)
  end
end
