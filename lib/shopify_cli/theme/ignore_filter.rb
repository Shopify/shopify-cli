# frozen_string_literal: true

module ShopifyCLI
  module Theme
    class IgnoreFilter
      FILE = ".shopifyignore"

      DEFAULT_REGEXES = [
        /\.git/,
        /\.hg/,
        /\.bzr/,
        /\.svn/,
        /_darcs/,
        /CVS/,
        /\.sublime-(project|workspace)/,
        /\.DS_Store/,
        /\.sass-cache/,
        /Thumbs\.db/,
        /desktop\.ini/,
        /config.yml/,
        /node_modules/,
      ].freeze

      DEFAULT_GLOBS = [].freeze

      attr_reader :root, :globs, :regexes

      def self.from_path(root)
        root = Pathname.new(root)
        ignore_file = root.join(FILE)
        patterns = if ignore_file.file?
          parse_ignore_file(ignore_file)
        else
          []
        end
        new(root, patterns: patterns)
      end

      def self.parse_ignore_file(file)
        patterns = []

        file.each_line do |line|
          line.strip!

          next if line.empty? || line.start_with?("#")

          patterns << line
        end

        patterns
      end

      def initialize(root, patterns: [])
        @root = root

        regexes, globs = patterns_to_regexes_and_globs(patterns)

        @regexes = regexes
        @globs = globs
      end

      def add_patterns(patterns)
        regexes, globs = patterns_to_regexes_and_globs(patterns)

        @regexes += regexes
        @globs += globs
      end

      def match?(path)
        path = path.to_s

        return true if path.empty?

        regexes.each do |regex|
          return true if regex.match(path)
        end

        globs.each do |glob|
          return true if ::File.fnmatch?(glob, path)
        end

        false
      end
      alias_method :ignore?, :match?

      private

      # Take in string patterns and convert them to either
      # regex patterns or glob patterns so that they are handled in an expected manner.
      def patterns_to_regexes_and_globs(patterns)
        new_regexes = DEFAULT_REGEXES.dup
        new_globs = DEFAULT_GLOBS.dup

        patterns.each do |pattern|
          pattern = pattern.strip

          if pattern.start_with?("/") && pattern.end_with?("/")
            new_regexes << Regexp.new(pattern.gsub(%r{^\/|\/$}, ""))
            next
          end

          # if specifying a directory, match everything below it
          pattern += "*" if pattern.end_with?("/")

          # The pattern will be scoped to root directory, so it should match anything
          # within that space
          pattern.prepend("*") unless pattern.start_with?("*")

          new_globs << pattern
        end

        [new_regexes, new_globs]
      end
    end
  end
end
