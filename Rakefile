require_relative 'bin/support/load_shopify'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs += %w(test)
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = false
  t.warning = false
end

desc("Start up irb with cli loaded")
task :console do
  exec('irb', '-r', './bin/support/load_shopify.rb', '-r', 'byebug')
end

namespace :rdoc do
  require 'rdoc/rdoc'
  require 'docgen/markdown'

  temp_path = '/tmp/shopify-app-cli-wiki'
  repo = 'https://github.com/Shopify/shopify-app-cli.wiki.git'
  intermediate = 'markdown_intermediate'
  file_to_doc = [
    'lib/shopify-cli/admin_api.rb',
    'lib/shopify-cli/db.rb',
    'lib/shopify-cli/git.rb',
    'lib/shopify-cli/heroku.rb',
    'lib/shopify-cli/partners_api.rb',
    'lib/shopify-cli/process_supervision.rb',
    'lib/shopify-cli/tunnel.rb',
  ]

  task all: [:markdown, :wiki, :cleanup]

  desc("Generate markdown files from rdoc comments")
  task :markdown do
    options = RDoc::Options.new
    options.setup_generator('markdown')
    options.op_dir = intermediate
    options.files = file_to_doc
    RDoc::RDoc.new.document(options)
  end

  desc("Copy markdown documentation to the wiki and commit them")
  task :wiki do
    system("git clone --depth=1 #{repo} #{temp_path}")
    FileUtils.cp(Dir[File.join(intermediate, '*.md')], "/tmp/shopify-app-cli-wiki")
    Dir.chdir(temp_path) do
      system('git add --all')
      system('git commit -am "auto doc update"')
      system('git push')
    end
  end

  desc("Clean up any documentation related files")
  task :cleanup do
    FileUtils.rm_r(intermediate)
    FileUtils.rm_rf(temp_path)
  end
end

desc("Generate markdown documentation and update the wiki")
task(rdoc: 'rdoc:all')
