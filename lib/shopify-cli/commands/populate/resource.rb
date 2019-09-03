require 'shopify_cli'
require 'optparse'

module ShopifyCli
  module Commands
    class Populate
      class Resource < ShopifyCli::Command
        include SmartProperties

        DEFAULT_COUNT = 5
        PAYLOAD_TYPE_WHITELIST = %w(SCALAR NON_NULL)

        attr_reader :api, :input

        class << self
          attr_accessor :type, :field, :input_type, :payload, :payload_blacklist
        end

        def call(args, _name)
          @args = args
          token = Helpers::AccessToken.read(@ctx)
          @api = Helpers::API.new(ctx: @ctx, token: token)
          @input = OpenStruct.new
          @count = DEFAULT_COUNT
          input_options
          options.parse(args)
          populate
        end

        def set_input
          defaults
          options.parse(@args)
        end

        def message
          raise NotImplementedError
        end

        def defaults
          raise NotImplementedError
        end

        def options
          @options ||= OptionParser.new do |opts|
            opts.banner = "\0"
            opts.on(
              "-c #{DEFAULT_COUNT}",
              "--count=#{DEFAULT_COUNT}",
              'Number of resources to generate'
            ) do |value|
              @count = value.to_i
            end

            opts.on(
              "-h",
              'print help'
            ) do |_value|
              puts opts
              exit
            end
          end
        end

        def populate
          @count.times do
            set_input
            @ctx.debug(mutation)
            run_mutation
          end
          completion_message
        end

        def input_options
          schema[self.class.input_type]['inputFields'].each do |field|
            options.on(
              "--#{field['name']}=#{field['defaultValue']}",
              field['description']
            ) do |value|
              @input[field['name']] = value
            end
          end
        end

        def input_fields
          @input_fields = schema[self.class.input_type]['inputFields'].each_with_object({}) do |field, obj|
            obj[field['name']] = field
            obj
          end
        end

        def to_input(struct)
          struct.to_h.map do |key, value|
            value = "\"#{value}\"" if input_fields[key.to_s]['type']['name'] == 'String'
            "#{key}: #{value}"
          end.join(',')
        end

        def mutation
          <<~MUTATION
            #{self.class.field}(input: {#{to_input(@input)}}) {
              #{self.class.type} {
                #{payload}
              }
            }
          MUTATION
        end

        def payload
          schema[Helpers::String.cap_first(self.class.type)]['fields']
            .each_with_object([]) do |field, obj|
            next unless field['args'].empty?
            next if self.class.payload_blacklist.include?(field['name'])
            next unless PAYLOAD_TYPE_WHITELIST.include?(field.dig('type', 'kind'))
            next unless PAYLOAD_TYPE_WHITELIST.include?(field.dig('type', 'ofType', 'kind'))
            obj << field['name']
          end.join(',')
        end

        def schema
          @schema ||= ShopifyCli::Helpers::SchemaParser.new(schema: @ctx.app_metadata[:schema])
        end

        def run_mutation
          resp = @api.mutation(mutation)
          raise(ShopifyCli::Abort, resp['errors']) if resp['errors']
          @ctx.done(message(resp['data']))
        end

        def success
          <<~SUCCESS
            {{v}} Successfully added #{self.class.type}s to {{green:#{Project.current.env.shop}}}
            {{*}} View all #{self.class.type}s at {{underline:#{admin_url}#{self.class.type}s}}
          SUCCESS
        end

        def completion_message
          @ctx.puts(success)
        end

        def admin_url
          "https://#{Project.current.env.shop}/admin/"
        end

        def price
          format('%.2f', rand(1..10))
        end
      end
    end
  end
end
