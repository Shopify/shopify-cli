# frozen_string_literal: true

module ShopifyCli
  module Helpers
    class EnvFile
      include SmartProperties

      FILENAME = '.env'

      class << self
        def read(directory = Dir.pwd)
          app_type = Project.at(directory).app_type
          template = parse_template(app_type.env_file)
          input = {}
          parse(directory).each do |key, value|
            input[template[key]] = value if template[key]
          end
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

      def write(ctx, app_type: Project.current.app_type)
        spin_group = CLI::UI::SpinGroup.new
        spin_group.add("writing #{FILENAME} file...") do |spinner|
          template = self.class.parse_template(app_type.env_file)
          output = []
          template.each do |key, value|
            output << "#{key}=#{send(value)}" if send(value)
          end
          ctx.print_task("writing #{FILENAME} file")
          ctx.write(FILENAME, output.join("\n") + "\n")
          spinner.update_title("#{FILENAME} saved")
        end
        spin_group.wait
      end
    end
  end
end
