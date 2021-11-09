require "shopify_cli"
require "optparse"

module ShopifyCLI
  class AdminAPI
    class PopulateResourceCommand < ShopifyCLI::Command::SubCommand
      DEFAULT_COUNT = 5

      attr_reader :input

      class << self
        attr_accessor :input_type

        # we override the call classmethod here because we parse options at runtime
        def call(args, command_name, _parent_command)
          cmd = new(@ctx)
          cmd.call(args, command_name)
        end

        def help
          cmd = new(@ctx)
          output = cmd.display_parent_help + "\n"
          output + cmd.display_parent_extended_help
        end
      end

      def call(args, _)
        @args = args
        @input = Hash.new
        @count = DEFAULT_COUNT
        @help = false
        @skip_shop_confirmation = false
        input_options
        resource_options.parse(@args)

        if @help
          output = display_parent_extended_help
          output += "\n#{@ctx.message("core.populate.options.header", camel_case_resource_type)}\n"
          output += resource_options.help
          return @ctx.puts(output)
        end

        ShopifyCLI::Tasks::ConfirmStore.call(@ctx) unless @skip_shop_confirmation
        @shop = AdminAPI.get_shop_or_abort(@ctx)
        if @silent
          spin_group = CLI::UI::SpinGroup.new
          spin_group.add(@ctx.message("core.populate.populating", @count, camel_case_resource_type)) do |spinner|
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

      def display_parent_help
        parent_command_klass.respond_to?(:help) ? parent_command_klass.help : ""
      end

      def display_parent_extended_help
        parent_command_klass.respond_to?(:extended_help) ? parent_command_klass.extended_help : ""
      end

      def resource_options
        @resource_options ||= OptionParser.new do |opts|
          opts.banner = ""
          opts.on(
            "-c #{DEFAULT_COUNT}",
            "--count=#{DEFAULT_COUNT}",
            @ctx.message("core.populate.options.count_help")
          ) do |value|
            @count = value.to_i
          end

          opts.on("-h", "--help", "print help") do |value|
            @help = value
          end

          opts.on("--silent") { |v| @silent = v }

          opts.on("--skip-shop-confirmation") { |v| @skip_shop_confirmation = v }
        end
      end

      def populate
        @count.times do
          run_mutation(defaults.merge(@input))
        end
      end

      def input_options
        schema.type(self.class.input_type)["inputFields"].each do |field|
          resource_options.on(
            "--#{field["name"]}=#{field["defaultValue"]}",
            field["description"]
          ) do |value|
            @input[field["name"]] = value
          end
        end
      end

      def schema
        @schema ||= AdminAPI::Schema.get(@ctx)
      end

      def run_mutation(data)
        kwargs = { input: data }
        kwargs[:shop] = @shop
        resp = AdminAPI.query(
          @ctx, "create_#{snake_case_resource_type}", **kwargs
        )
        @ctx.abort(resp["errors"]) if resp["errors"]
        @ctx.done(message(resp["data"])) unless @silent
      end

      def completion_message
        plural = @count > 1 ? "s" : ""
        @ctx.message(
          "core.populate.completion_message",
          @count,
          "#{camel_case_resource_type}#{plural}",
          @shop,
          camel_case_resource_type,
          admin_url,
          snake_case_resource_type
        )
      end

      def admin_url
        "https://#{@shop}/admin/"
      end

      def price
        format("%.2f", rand(1..10))
      end

      private

      def camel_case_resource_type
        @camel_case_resource_type ||= self.class.to_s.split("::").last
      end

      def snake_case_resource_type
        @snake_case_resource_type ||= camel_case_resource_type.to_s
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr("-", "_")
          .downcase
      end

      def parent_command_klass
        @parent_command_klass ||= Module.const_get(self.class.to_s.split("::")[0..-2].join("::"))
      end
    end
  end
end
