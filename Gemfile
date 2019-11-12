# NOTE: These are development-only dependencies
source "https://rubygems.org"

# None of these can actually be used in a development copy of dev
# They are all for CI and tests
# `dev` uses no gems
group :development, :test do
  gem 'rake'
  gem 'byebug'
  gem 'rubocop'
end

group :test do
  gem 'session'
  gem 'mocha', require: false
  gem 'minitest', '>= 5.0.0', require: false
  gem 'minitest-reporters', require: false
  gem 'fakefs', require: false
  gem 'webmock', require: false
end
