require "rbconfig"
require "fileutils"
require "date"

gem = File.expand_path("../../../", __FILE__)
exe = File.join(gem, "bin", "shopify")

# `--skip-cli-build` will be passed from the brew `shopify-cli.rb` formula, so
# as to prevent this extension builder doing the script and sym-link creation;
# the brew install process takes care of these itself - see
# https://github.com/Shopify/homebrew-shopify/shopify-cli.rb
if ARGV && ARGV[0]&.match(/skip-cli-build/)
  makefile_content = <<~MAKEFILE
    .PHONY: clean

    clean: ;

    install: ;
  MAKEFILE
elsif RUBY_PLATFORM.match(/mswin|mingw|cygwin/)
  bat_path = File.dirname(RbConfig.ruby)
  bat = "#{bat_path}\\shopify.bat"

  script_content = "#{RbConfig.ruby} -I '#{gem}' '#{exe}' %*"

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
    #{RbConfig.ruby} -I #{gem} #{exe} $@
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
