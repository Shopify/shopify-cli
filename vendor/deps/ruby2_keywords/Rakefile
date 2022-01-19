require "bundler/gem_tasks"
require "rake/testtask"

helper = Bundler::GemHelper.instance

Rake::TestTask.new(:test) do |t|
  t.test_files = FileList["test/**/test_*.rb"]
end

task :default => :test

task "build" => "date_epoch"

task "date_epoch" do
  ENV["SOURCE_DATE_EPOCH"] = IO.popen(%W[git -C #{__dir__} log -1 --format=%ct], &:read).chomp
end

def helper.update_gemspec
  path = "#{__dir__}/#{gemspec.name}.gemspec"
  File.open(path, "r+b") do |f|
    if (d = f.read).sub!(/^(version\s*=\s*)".*"/) {$1 + gemspec.version.to_s.dump}
      f.rewind
      f.truncate(0)
      f.print(d)
    end
  end
end

def helper.commit_bump
  sh(%W[git -C #{__dir__} commit -m bump\ up\ to\ #{gemspec.version}
        #{gemspec.name}.gemspec])
end

def helper.version=(v)
  gemspec.version = v
  update_gemspec
  commit_bump
  tag_version
end
major, minor, teeny = helper.gemspec.version.segments

task "bump:teeny" do
  helper.version = Gem::Version.new("#{major}.#{minor}.#{teeny+1}")
end

task "bump:minor" do
  raise "can't bump up minor"
end

task "bump:major" do
  raise "can't bump up major"
end

task "bump" => "bump:teeny"
