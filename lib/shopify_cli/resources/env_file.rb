# frozen_string_literal: true

module ShopifyCLI
  module Resources
    class EnvFile
      include SmartProperties
      FILENAME = ".env"
      KEY_MAP = {
        "SHOPIFY_API_KEY" => :api_key,
        "SHOPIFY_API_SECRET" => :secret,
        "SHOP" => :shop,
        "SCOPES" => :scopes,
        "HOST" => :host,
      }

      class << self
        def path(directory)
          File.join(directory, FILENAME)
        end

        def read(_directory = Dir.pwd, overrides: {})
          input = parse_external_env(overrides: overrides)
          new(input)
        end

        def from_hash(hash)
          new(env_input(hash))
        end

        def parse(directory)
          File.read(path(directory))
            .gsub("\r\n", "\n").split("\n").each_with_object({}) do |line, output|
            match = /\A(#*\s*[A-Za-z_0-9]+)\s*=\s*(.*)\z/.match(line)
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

        def parse_external_env(directory = Dir.pwd, overrides: {})
          env_input(parse(directory), overrides: overrides)
        end

        def env_input(parsed_source, overrides: {})
          env_details = {}
          extra = {}
          parsed_source.merge(overrides).each do |key, value|
            if KEY_MAP[key]
              env_details[KEY_MAP[key]] = value
            else
              extra[key] = value
            end
          end
          env_details[:extra] = extra
          env_details
        end
      end

      property :api_key, required: true
      property :secret
      property :shop
      property :scopes
      property :host
      property :extra, default: -> { {} }

      def to_h
        out = {}
        KEY_MAP.each do |key, value|
          out[key] = send(value).to_s if send(value)
        end
        extra.each do |key, value|
          out[key] = value.to_s
        end
        out
      end

      def write(ctx)
        spin_group = CLI::UI::SpinGroup.new
        spin_group.add(ctx.message("core.env_file.saving_header", FILENAME)) do |spinner|
          output = []
          KEY_MAP.each do |key, value|
            output << "#{key}=#{send(value)}" if send(value)
          end
          extra.each do |key, value|
            output << "#{key}=#{value}"
          end
          ctx.print_task(ctx.message("core.env_file.saving", FILENAME))
          ctx.write(FILENAME, output.join("\n") + "\n")
          spinner.update_title(ctx.message("core.env_file.saved", FILENAME))
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
