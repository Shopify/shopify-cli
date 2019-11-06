# frozen_string_literal: true

module ShopifyCli
  module Helpers
    class EnvFile
      include SmartProperties
      FILENAME = '.env'
      KEY_MAP = {
        'SHOPIFY_API_KEY' => :api_key,
        'SHOPIFY_API_SECRET' => :secret,
        'SHOP' => :shop,
        'SCOPES' => :scopes,
        'HOST' => :host,
      }

      class << self
        def read(directory = Dir.pwd)
          input = {}
          extra = {}
          parse(directory).each do |key, value|
            if KEY_MAP[key]
              input[KEY_MAP[key]] = value
            else
              extra[key] = value
            end
          end
          input[:extra] = extra
          new(input)
        end

        def parse(directory)
          File.read(File.join(directory, FILENAME))
            .gsub("\r\n", "\n").split("\n").each_with_object({}) do |line, output|
            match = /\A([A-Za-z_0-9]+)=(.*)\z/.match(line)
            if match
              key = match[1]
              output[key] = case match[2]
              # Remove single quotes
              when /\A'(.*)'\z/ then match[2]
              # Remove double quotes and unescape string preserving newline characters
              when /\A"(.*)"\z/ then match[2].gsub('\n', "\n").gsub(/\\(.)/, '\1')
              else match[2]
              end
            end
            output
          end
        end
      end

      property :api_key, required: true
      property :secret, required: true
      property :shop
      property :scopes
      property :host
      property :extra, default: {}

      def write(ctx)
        spin_group = CLI::UI::SpinGroup.new
        spin_group.add("writing #{FILENAME} file...") do |spinner|
          output = []
          KEY_MAP.each do |key, value|
            output << "#{key}=#{send(value)}" if send(value)
          end
          extra.each do |key, value|
            output << "#{key}=#{value}"
          end
          ctx.print_task("writing #{FILENAME} file")
          ctx.write(FILENAME, output.join("\n") + "\n")
          spinner.update_title("#{FILENAME} saved")
        end
        spin_group.wait
      end

      def update(ctx, field, value)
        self[field] = value
        write(ctx)
      end
    end
  end
end
