require 'shopify_cli'
require 'optparse'

module ShopifyCli
  module Commands
    class Populate
      class Resource < ShopifyCli::SubCommand
        DEFAULT_COUNT = 5

        attr_reader :input

        class << self
          attr_accessor :input_type

          # we override the call classmethod here because we parse options at runtime
          def call(args, command_name, _parent_command)
            cmd = new(@ctx)
            cmd.call(args, command_name)
          end
        end

        def call(args, _)
          return unless Project.at(Dir.pwd)
          Tasks::EnsureEnv.call(@ctx)
          @args = args
          @input = Hash.new
          @count = DEFAULT_COUNT
          @help = false
          input_options
          resource_options.parse(@args)

          if @help
            output = Populate.extended_help
            output += "\n{{bold:{{cyan:#{resource_type.capitalize}}} options:}}\n"
            output += resource_options.help
            return @ctx.page(output)
          end

          if @silent
            spin_group = CLI::UI::SpinGroup.new
            spin_group.add("Populating #{@count} #{resource_type}s...") do |spinner|
              populate
              spinner.update_title(completion_message)
            end
            spin_group.wait
          else
            populate
            @ctx.puts(completion_message)
          end
        end

        def message
          raise NotImplementedError
        end

        def defaults
          raise NotImplementedError
        end

        def resource_options
          @resource_options ||= OptionParser.new do |opts|
            opts.banner = ""
            opts.on("-c #{DEFAULT_COUNT}", "--count=#{DEFAULT_COUNT}", 'Number of resources to generate') do |value|
              @count = value.to_i
            end

            opts.on('-h', '--help', 'print help') do |value|
              @help = value
            end

            opts.on("--silent") { |v| @silent = v }

            opts.on('--shop=', '-s') { |value| @shop = value }
          end
        end

        def populate
          @count.times do
            run_mutation(defaults.merge(@input))
          end
        end

        def input_options
          schema[self.class.input_type]['inputFields'].each do |field|
            resource_options.on(
              "--#{field['name']}=#{field['defaultValue']}",
              field['description']
            ) do |value|
              @input[field['name']] = value
            end
          end
        end

        def resource_type
          @resource_type ||= self.class.to_s.split('::').last.downcase
        end

        def schema
          @schema ||= ShopifyCli::Helpers::SchemaParser.new(schema: @ctx.app_metadata[:schema])
        end

        def run_mutation(data)
          kwargs = { input: data }
          kwargs[:shop] = @shop if @shop
          resp = Helpers::AdminAPI.query(
            @ctx, "create_#{resource_type}", kwargs
          )
          @ctx.error(resp['errors']) if resp['errors']
          @ctx.done(message(resp['data'])) unless @silent
        end

        def completion_message
          <<~COMPLETION_MESSAGE
            Successfully added #{@count} #{resource_type}s to {{green:#{Project.current.env.shop}}}
            {{*}} View all #{resource_type}s at {{underline:#{admin_url}#{resource_type}s}}
          COMPLETION_MESSAGE
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
