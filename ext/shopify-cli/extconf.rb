require 'rbconfig'
require 'fileutils'

gem = File.expand_path('../../../', __FILE__)
exe = File.join(gem, 'bin', 'shopify-cli')
script = exe + '.sh'
symlink = '/usr/local/bin/shopify-cli'

script_content = <<~SCRIPT
  #!/usr/bin/env bash
  #{RbConfig.ruby} --disable=gems -I #{gem} #{exe} $@
SCRIPT

File.write(script, script_content)
FileUtils.chmod("+x", script)

makefile_content = <<~MAKEFILE
  .PHONY: clean install
  
  clean:
  \t@sudo rm -f #{symlink}
  
  install: clean
  \t@sudo ln -s #{script} #{symlink}
MAKEFILE

File.write('Makefile', makefile_content)
