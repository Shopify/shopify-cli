require_relative "bin/load_shopify"
require "rake/testtask"
require "rubocop/rake_task"
require "bundler/gem_tasks"
require "shellwords"

Rake::TestTask.new do |t|
  t.libs += %w(test)
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = false
  t.warning = false
end

desc "Runs the test suite in a Linux Docker environment"
task :test_linux do
  system("docker", "build", __dir__, "-t", "shopify-cli") || abort
  system(
    "docker", "run", 
    "-t", "--rm", 
    "--volume", "#{Shellwords.escape(__dir__)}:/usr/src/app", 
    "shopify-cli", 
    "bundle", "exec", "rake" , "test"
  ) || abort
end

RuboCop::RakeTask.new

task(default: [:test, :rubocop])

desc("Start up irb with cli loaded")
task :console do
  exec("irb", "-r", "./bin/load_shopify.rb", "-r", "byebug")
end

namespace :rdoc do
  repo = "https://github.com/Shopify/shopify-cli.wiki.git"
  intermediate = "markdown_intermediate"
  file_to_doc = [
    "lib/shopify-cli/admin_api.rb",
    "lib/shopify-cli/context.rb",
    "lib/shopify-cli/db.rb",
    "lib/shopify-cli/git.rb",
    "lib/shopify-cli/heroku.rb",
    "lib/shopify-cli/js_deps.rb",
    "lib/shopify-cli/lazy_delegator.rb",
    "lib/shopify-cli/method_object.rb",
    "lib/shopify-cli/partners_api.rb",
    "lib/shopify-cli/process_supervision.rb",
    "lib/shopify-cli/project.rb",
    "lib/shopify-cli/result.rb",
    "lib/shopify-cli/transform_data_structure.rb",
    "lib/shopify-cli/tunnel.rb",
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
  require "shopify-cli/packager"

  task all: [:debian, :rpm, :homebrew]

  desc("Builds a Debian package of the CLI")
  task :debian do
    ShopifyCli::Packager.new.build_debian
  end

  desc("Builds an RPM package of the CLI")
  task :rpm do
    ShopifyCli::Packager.new.build_rpm
  end

  desc("Builds a Homebrew package of the CLI")
  task :homebrew do
    ShopifyCli::Packager.new.build_homebrew
  end
end

desc("Builds all distribution packages of the CLI")
task(package: "package:all")
