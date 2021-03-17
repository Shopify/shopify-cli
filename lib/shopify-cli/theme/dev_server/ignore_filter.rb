# frozen_string_literal: true

module ShopifyCli
  module Theme
    module DevServer
      class IgnoreFilter
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

        class IgnoreFileDoesNotExist < StandardError; end

        def initialize(root, patterns: [], files: [])
          @root = root

          file_patterns = files_to_patterns(files)
          regexes, globs = patterns_to_regexes_and_globs(file_patterns + patterns)

          @regexes = regexes
          @globs = globs
        end

        def match?(path)
          return true if path.empty?

          regexes.each do |regex|
            return true if regex.match(path)
          end

          globs.each do |glob|
            return true if File.fnmatch?(glob, path)
          end

          false
        end

        private

        # Load files containing patterns and parse them
        def files_to_patterns(files)
          patterns = []

          files.each do |file|
            begin
              text = File.read(Pathname.new(@root).join(file))
            rescue Errno::ENOENT
              raise IgnoreFileDoesNotExist, "#{file} does not exist"
            end

            text.split("\n").each do |line|
              line.strip!

              next if line.empty? || line.start_with?("#")

              patterns << line
            end
          end

          patterns
        end

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
end
