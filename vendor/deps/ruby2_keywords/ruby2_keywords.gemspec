version = "0.0.4"
abort "Version must not reach 1" if version[/\d+/].to_i >= 1

Gem::Specification.new do |s|
  s.name = "ruby2_keywords"
  s.version = version
  s.summary = "Shim library for Module#ruby2_keywords"
  s.homepage = "https://github.com/ruby/ruby2_keywords"
  s.licenses = ["Ruby", "BSD-2-Clause"]
  s.authors = ["Nobuyoshi Nakada"]
  s.require_paths = ["lib"]
  s.rdoc_options = ["--main", "README.md"]
  s.files = [
    "LICENSE",
    "README.md",
    "lib/ruby2_keywords.rb",
  ]
end
