# frozen_string_literal: true

module ShopifyCli
  module Helpers
    class EnvFile
      include SmartProperties

      class << self
        def read(app_type, filename)
          template = parse_template(app_type.class.env_file)
          input = {}
          parse(filename).each do |key, value|
            input[template[key]] = value if template[key]
          end
          input[:app_type] = app_type
          new(input)
        end

        def parse_template(template)
          template.split("\n").each_with_object({}) do |line, output|
            match = /\A([A-Za-z_0-9]+)=\{(.*)\}\z/.match(line)
            if match
              output[match[1]] = match[2]
            end
            output
          end
        end

        def parse(filename)
          File.read(filename).gsub("\r\n", "\n").split("\n").each_with_object({}) do |line, output|
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

      property :app_type, required: true
      property :api_key, required: true
      property :secret, required: true
      property :shop
      property :scopes
      property :host

      def write(ctx, filename)
        template = self.class.parse_template(app_type.class.env_file)
        output = []
        template.each do |key, value|
          output << "#{key}=#{send(value)}" if send(value)
        end
        ctx.print_task('writing .env file')
        ctx.write(filename, output.join("\n") + "\n")
      end
    end
  end
end
