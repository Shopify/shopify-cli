ENV["SHOPIFY_CLI_TEST"] = "1"

require_relative "bin/load_shopify"
require_relative "utilities/utilities"
require_relative "lib/shopify_cli/constants"
require_relative "lib/shopify_cli/version"
require "rake/testtask"
require "rubocop/rake_task"
require "bundler/gem_tasks"
require "shellwords"
require "digest"
require "open3"

Rake::TestTask.new do |t|
  t.libs += %w(test)
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = false
  t.warning = false
end

desc "A set of tasks that run in Linux environments"
namespace :linux do
  desc "Runs the test suite in a Linux Docker environment"
  task :test do
    Utilities::Docker.run_and_rm_container("bundle", "exec", "rake", "test")
  end
end

RuboCop::RakeTask.new

task(default: [:test, :rubocop])

desc("Start up irb with cli loaded")
task :console do
  exec("irb", "-r", "./bin/load_shopify.rb", "-r", "byebug")
end

desc("Notifies a new version to Bugsnag")
task :notify_version_to_bugsnag do
  # This task runs at deployment time to notify
  # Bugsnag about new versions. Because the deployment
  # environment has Node, we can run the Bugsnag CLI
  # through npx.
  system(
    { "npm_config_yes" => "true" },
    "npx", "-q", "bugsnag-build-reporter",
    "-k", ShopifyCLI::Constants::Bugsnag::API_KEY,
    "-v", ShopifyCLI::VERSION
  ) || abort
end

namespace :rdoc do
  repo = "https://github.com/Shopify/shopify-cli.wiki.git"
  intermediate = "markdown_intermediate"
  file_to_doc = [
    "lib/shopify_cli/admin_api.rb",
    "lib/shopify_cli/context.rb",
    "lib/shopify_cli/db.rb",
    "lib/shopify_cli/git.rb",
    "lib/shopify_cli/heroku.rb",
    "lib/shopify_cli/js_deps.rb",
    "lib/shopify_cli/lazy_delegator.rb",
    "lib/shopify_cli/method_object.rb",
    "lib/shopify_cli/partners_api.rb",
    "lib/shopify_cli/process_supervision.rb",
    "lib/shopify_cli/project.rb",
    "lib/shopify_cli/result.rb",
    "lib/shopify_cli/transform_data_structure.rb",
    "lib/shopify_cli/tunnel.rb",
  ]

  task all: [:markdown, :wiki, :cleanup]

  desc("Generate markdown files from rdoc comments")
  task :markdown do
    require "rdoc/rdoc"
    require "docgen/markdown"
    options = RDoc::Options.new
    options.setup_generator("markdown")
    options.op_dir = intermediate
    options.files = file_to_doc
    RDoc::RDoc.new.document(options)
  end

  desc("Copy markdown documentation to the wiki and commit them")
  task :wiki do
    require "tmpdir"
    Dir.mktmpdir do |temp_dir|
      system("git clone --depth=1 #{repo} #{temp_dir}")
      FileUtils.cp(Dir[File.join(intermediate, "*.md")], temp_dir)
      Dir.chdir(temp_dir) do
        system("git add --all")
        system('git commit -am "auto doc update"')
        system("git push")
      end
    end
  end

  desc("Clean up any documentation related files")
  task :cleanup do
    FileUtils.rm_r(intermediate)
  end
end

desc("Generate markdown documentation and update the wiki")
task(rdoc: "rdoc:all")

namespace :package do
  require "shopify_cli/packager"

  task all: [:debian, :rpm, :homebrew]

  desc("Builds a Debian package of the CLI")
  task :debian do
    ShopifyCLI::Packager.new.build_debian
  end

  desc("Builds an RPM package of the CLI")
  task :rpm do
    ShopifyCLI::Packager.new.build_rpm
  end

  desc("Builds a Homebrew package of the CLI")
  task :homebrew do
    ShopifyCLI::Packager.new.build_homebrew
  end
end

desc("Builds all distribution packages of the CLI")
task(package: "package:all")

namespace :changelog do
  require "shopify_cli/changelog"

  task :update do
    ShopifyCLI::Changelog.new.update!
  end
end

namespace :release do
  require "shopify_cli/release"

  task :prepare, [:new_version] do |_t, args|
    new_version = args[:new_version]
    unless new_version
      raise <<~NO_NEW_VERSION
        New version must be provided, e.g.:

        $ GITHUB_ACCESS_TOKEN=abcdef rake "release:prepare[1.2.3]"

      NO_NEW_VERSION
    end
    github_access_token = ENV["GITHUB_ACCESS_TOKEN"]
    unless github_access_token
      raise <<~NO_GITHUB_ACCESS_TOKEN
        GitHub access token must be provided, e.g.:

        $ GITHUB_ACCESS_TOKEN=abcdef rake "release:prepare[1.2.3]"
      NO_GITHUB_ACCESS_TOKEN
    end

    ShopifyCLI::Release.new(new_version, github_access_token).prepare!
    puts "Completed!"
  end

  task :package do
    github_access_token = ENV["GITHUB_ACCESS_TOKEN"]
    unless github_access_token
      raise <<~NO_GITHUB_ACCESS_TOKEN
        GitHub access token must be provided, e.g.:

        $ GITHUB_ACCESS_TOKEN=abcdef rake release:package
      NO_GITHUB_ACCESS_TOKEN
    end
    ShopifyCLI::Release.new(ShopifyCLI::VERSION, github_access_token).package!
    puts "Completed!"
  end
end

namespace :extensions do
  task :update do
    version = ENV.fetch("VERSION").strip
    error("Invalid version") unless /^v\d+\.\d+\.\d+/.match(version)
    File.write(Paths.extension("version"), version)
  end

  task :symlink do
    source = Paths.root("..", "shopify-cli-extensions", "shopify-extensions")
    error("Unable to find shopify-extensions executable: #{executable}") unless File.executable?(source)
    target = Paths.extension("shopify-extensions")
    File.delete(target) if File.exist?(target)
    File.symlink(source, target)
  end

  task :install do
    target = Paths.extension("shopify-extensions")
    require_relative Paths.extension("shopify_extensions.rb")
    File.delete(target) if File.exist?(target)
    ShopifyExtensions.install(target: target)
  end

  module Paths
    def self.extension(*args)
      root("ext", "shopify-extensions", *args)
    end

    def self.root(*args)
      Pathname(File.dirname(__FILE__)).join(*args).to_s
    end
  end
end

namespace :scripts do
  namespace :javy do
    task :symlink do
      source = Paths.root("..", "javy", "target", "release", "javy")
      error("Unable to find javy executable: #{executable}") unless File.executable?(source)
      target = Paths.javy("javy")
      File.delete(target) if File.exist?(target)
      File.symlink(source, target)
    end

    task :install do
      require_relative Paths.javy("javy.rb")
      Javy.install
    end

    module Paths
      def self.javy(*args)
        root("ext", "javy", *args)
      end

      def self.root(*args)
        Pathname(File.dirname(__FILE__)).join(*args).to_s
      end
    end
  end
end

def error(message, output: STDERR, code: 1)
  output.puts(message)
  exit(code)
end
