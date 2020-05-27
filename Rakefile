require_relative 'bin/support/load_shopify'
require 'rake/testtask'
require 'rubocop/rake_task'

Rake::TestTask.new do |t|
  t.libs += %w(test)
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = false
  t.warning = false
end

RuboCop::RakeTask.new

task(default: [:test, :rubocop])

desc("Start up irb with cli loaded")
task :console do
  exec('irb', '-r', './bin/support/load_shopify.rb', '-r', 'byebug')
end

namespace :rdoc do
  repo = 'https://github.com/Shopify/shopify-app-cli.wiki.git'
  intermediate = 'markdown_intermediate'
  file_to_doc = [
    'lib/shopify-cli/admin_api.rb',
    'lib/shopify-cli/context.rb',
    'lib/shopify-cli/db.rb',
    'lib/shopify-cli/git.rb',
    'lib/shopify-cli/heroku.rb',
    'lib/shopify-cli/js_deps.rb',
    'lib/shopify-cli/partners_api.rb',
    'lib/shopify-cli/process_supervision.rb',
    'lib/shopify-cli/project.rb',
    'lib/shopify-cli/tunnel.rb',
  ]

  task all: [:markdown, :wiki, :cleanup]

  desc("Generate markdown files from rdoc comments")
  task :markdown do
    require 'rdoc/rdoc'
    require 'docgen/markdown'
    options = RDoc::Options.new
    options.setup_generator('markdown')
    options.op_dir = intermediate
    options.files = file_to_doc
    RDoc::RDoc.new.document(options)
  end

  desc("Copy markdown documentation to the wiki and commit them")
  task :wiki do
    require 'tmpdir'
    Dir.mktmpdir do |temp_dir|
      system("git clone --depth=1 #{repo} #{temp_dir}")
      FileUtils.cp(Dir[File.join(intermediate, '*.md')], temp_dir)
      Dir.chdir(temp_dir) do
        system('git add --all')
        system('git commit -am "auto doc update"')
        system('git push')
      end
    end
  end

  desc("Clean up any documentation related files")
  task :cleanup do
    FileUtils.rm_r(intermediate)
  end
end

desc("Generate markdown documentation and update the wiki")
task(rdoc: 'rdoc:all')
