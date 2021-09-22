require_relative "lib/shopify_cli/version"

Gem::Specification.new do |spec|
  spec.name = "shopify-cli"
  spec.version = ShopifyCLI::VERSION
  spec.authors = ["Shopify"]
  spec.email = ["dev-tools-education@shopify.com"]
  spec.license = "MIT"

  spec.summary = "Shopify CLI helps you build Shopify apps faster."
  spec.description = <<~HERE
    Shopify CLI helps you build Shopify apps faster. It quickly scaffolds Node.js
    and Ruby on Rails embedded apps. It also automates many common tasks in the
    development process and lets you quickly add popular features, such as billing
    and webhooks.
  HERE
  spec.homepage = "https://shopify.github.io/shopify-cli/"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Shopify/shopify-cli"
  spec.metadata["changelog_uri"] = "https://github.com/Shopify/shopify-cli/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    %x(git ls-files -z).split("\x0").reject do |f|
      f.match(%r{^(test|spec|features|packaging)/}) ||
      f.match(%r{^bin/(update-deps|shopify.bat)$})
    end
  end
  spec.bindir = "bin"
  spec.require_paths = ["lib", "vendor"]
  spec.extensions = ["ext/shopify-cli/extconf.rb"]
  # Do NOT include `shopify` as a listed executable via `spec.executables`.
  # `ext/shopify-cli/extconf.rb` will dynamically create a script and soft-link
  # `/usr/local/bin/shopify` to that script, in order to "lock" the Ruby used to
  # a single Ruby (useful for debugging in multi-Ruby environments)

  spec.add_development_dependency("bundler", "~> 2.2.2")
  spec.add_development_dependency("rake", "~> 12.3", ">= 12.3.3")
  spec.add_development_dependency("minitest", "~> 5.0")

  spec.add_dependency("listen", "~> 3.7.0")
  spec.add_dependency("theme-check", "~> 1.4.0")
end
