# frozen_string_literal: true

module ShopifyCLI
  module Theme
    class Syncer
      class UnsupportedScriptWarning
        attr_reader :ctx

        def initialize(ctx, file)
          @ctx = ctx
          @file = file
        end

        def to_s
          "\n\n#{occurrences} #{long_text}"
        end

        private

        def occurrences
          warnings.map { |w| occurrence(w) }.join("\n")
        end

        def occurrence(warning)
          line_number = "{{blue: #{warning.line} |}}"
          pointer = pointer_message(warning)

          <<~OCCURRENCE
            #{line_number} #{warning.line_content}
            #{pointer}
          OCCURRENCE
        end

        def long_text
          lines_and_columns = warnings.map do |warning|
            message("line_and_column", warning.line, warning.column)
          end

          message("unsupported_script_text", lines_and_columns.join)
            .split("\n")
            .reduce("") do |text, line|
              # Add indentation in the long text to improve readability
              line = " #{line}"

              # Inline yellow (otherwise `CLI::UI::Frame` breaks multiline formatting)
              line = "{{yellow:#{line}}}"

              "#{text}#{line}\n"
            end
        end

        def pointer_message(warning)
          padding = warning.column + warning.line.to_s.size + 2
          text = message("unsupported_script")

          "{{yellow:#{" " * padding} ^ {{bold:#{text}}}}}"
        end

        def message(*args)
          key = args.shift
          @ctx.message("theme.serve.syncer.warnings.#{key}", *args)
        end

        def warnings
          @warnings ||= @file.warnings.map { |w| Warning.new(@file, w) }
        end

        class Warning
          attr_reader :line, :column

          def initialize(file, warning_hash)
            @file = file
            @line = warning_hash["line"].to_i
            @column = warning_hash["column"].to_i
          end

          def line_content
            file_lines[line - 1]
          end

          private

          def file_lines
            @file_lines ||= @file.read.split("\n")
          end
        end
      end
    end
  end
end
