begin
  addpath = lambda do |p|
    path = File.expand_path("../../#{p}", __FILE__)
    $LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
  end
  addpath.call("lib")
end

require 'cli/kit'

require 'fileutils'
require 'tmpdir'
require 'tempfile'

require 'rubygems'
require 'bundler/setup'

require 'byebug'

CLI::UI::StdoutRouter.enable

require 'minitest/autorun'
require "minitest/unit"
require 'mocha/minitest'

def with_env(env)
  original_env_hash = ENV.to_h
  ENV.replace(original_env_hash.merge(env))
  yield
ensure
  ENV.replace(original_env_hash)
end
