require "rbconfig"
require "fileutils"

gem = File.expand_path("../../../", __FILE__)
exe = File.join(gem, "bin", "shopify")

if RUBY_PLATFORM.match(/mingw32/)
  bat_path = File.dirname(RbConfig.ruby)
  bat = "#{bat_path}\\shopify.bat"

  script_content = "#{RbConfig.ruby} --disable=gems -I '#{gem}' '#{exe}' %*"

  FileUtils.mkdir_p(bat_path)
  makefile_content = <<~MAKEFILE
    .PHONY: clean install

    clean:
    \t rm -f "#{bat}"

    install: clean
    \t echo "@ECHO OFF"> "#{bat}"
    \t echo "#{script_content}">> "#{bat}"
  MAKEFILE
else
  script = exe + ".sh"
  symlink = "/usr/local/bin/shopify"

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
end

File.write("Makefile", makefile_content)
