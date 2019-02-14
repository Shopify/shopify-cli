#!/usr/bin/ruby --disable-gems

lib_path = File.expand_path("../../../lib", __FILE__)
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)

ENV['SHELLPID'] ||= Process.ppid.to_s
ENV['USER_PWD'] ||= Dir.pwd

# Prune non-absolute paths from PATH to prevent non-deterministic behavior
# i.e. If user has "." or "./bin" in their PATH
# Note that this logic is duplicated in lib/shopify.rb
ENV['PATH'] = ENV['PATH'].split(':').select { |p| p.start_with?('/', '~') }.join(':')

$original_env = ENV.to_hash

require 'shopify_cli'

if ENV['PRINT_LOADED_FEATURES']
  puts $LOADED_FEATURES
end
