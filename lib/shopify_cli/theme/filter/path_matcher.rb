# frozen_string_literal: true

module ShopifyCLI
  module Theme
    module Filter
      module PathMatcher
        def regex_match?(regex, path)
          regex.match?(path)
        rescue StandardError
          false
        end

        def glob_match?(glob, path)
          !!::File.fnmatch?(glob, path)
        end

        def regex?(pattern)
          pattern.start_with?("/") && pattern.end_with?("/")
        end

        def as_regex(pattern)
          Regexp.new(pattern.gsub(%r{^\/|\/$}, ""))
        end

        def as_glob(pattern)
          # if specifying a directory, match everything below it
          pattern += "*" if pattern.end_with?("/")

          # The pattern will be scoped to root directory, so it should match anything
          # within that space
          pattern.prepend("*") unless pattern.start_with?("*")

          pattern
        end
      end
    end
  end
end
