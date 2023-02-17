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
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7")

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
  spec.executables << "shopify"

  spec.add_development_dependency("bundler", ">= 2.3.11")
  spec.add_development_dependency("rake", "~> 12.3", ">= 12.3.3")
  spec.add_development_dependency("minitest", "~> 5.0")

  spec.add_dependency("bugsnag", "~> 6.22")
  spec.add_dependency("listen", "~> 3.7.0")

  # We prefer being more strict here with the version range to have a more deterministic build.
  # The added benefit is that, if the user upgrades the CLI, and we have "~> 1.10.1" version range,
  # they will get a theme-check update.
  # Whereas if we were to have "~> 1.9", that version would still be satisfied and thus not upgraded.
  # Both shopify-cli and theme-check gems are owned and developed by Shopify.
  # These gems are currently being actively developed and it's easiest to update them together.
  spec.add_dependency("theme-check", "~> 1.14.0")

  spec.extensions = ["ext/shopify-extensions/extconf.rb"]
end
