module ShopifyCli
  module Resources
    class ReadEnvFile
      include MethodObject

      noop = ->(value) { value }
      property! :transform_keys, converts: :to_proc, default: -> { noop }
      property! :transform_values, converts: :to_proc, default: -> { noop }

      def call(path)
        Result
          .wrap(path)
          .then(&method(:read))
          .then(&method(:tokenize))
          .then(&method(:transform))
      end

      private

      def read(path)
        File.read(path)
      end

      def tokenize(data)
        data
          .gsub("\r\n", "\n")
          .split("\n")
          .lazy
          .map { |line| /\A([A-Za-z_0-9]+)=(.*)\z/.match(line)&.captures }
          .reject(&:nil?)
      end

      def transform(tokens)
        tokens.each_with_object({}) do |(key, value), env|
          env[transform_keys[key]] = sanitize(transform_values[value])
        end
      end

      def sanitize(value)
        case value
          # FIXME: Quotes aren't actually removed – this is a copy of the original code.
          # Remove single quotes
        when /\A'(.*)'\z/ then value
          # Remove double quotes and unescape string preserving newline characters
        when /\A"(.*)"\z/ then value.gsub('\n', "\n").gsub(/\\(.)/, '\1')
        else
          value
        end
      end
    end
  end
end
