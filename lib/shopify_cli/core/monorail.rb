require "json"
require "net/http"
require "time"
require "rbconfig"

module ShopifyCLI
  module Core
    module Monorail
      ENDPOINT_URI = URI.parse("https://monorail-edge.shopifysvc.com/v1/produce")
      INVOCATIONS_SCHEMA = "app_cli_command/5.0"

      # Extra hash of data that will be sent in the payload
      @metadata = {}

      class << self
        attr_accessor :metadata

        def log(name, args, &block) # rubocop:disable Lint/UnusedMethodArgument
          command, command_name = Commands::Registry.lookup_command(name)
          full_command = self.full_command(command, args, resolved_command: [command_name])

          start_time = now_in_milliseconds
          err = nil

          begin
            yield
          rescue Exception => e # rubocop:disable Lint/RescueException
            err = e
            raise
          ensure
            # If there's an error, we don't prompt from here and we let the exception
            # reporter do that.
            if report?(prompt: err.nil?)
              send_event(start_time, full_command, args - full_command, err&.message)
            end
          end
        end

        def full_command(command, args, resolved_command:)
          resolved_command = resolved_command.dup
          if command
            subcommand, subcommand_name = command.subcommand_registry.lookup_command(args.first)
            resolved_command << subcommand_name if subcommand
            if subcommand&.subcommand_registry
              resolved_command = full_command(subcommand, args.drop(1), resolved_command: resolved_command)
            end
          end
          resolved_command
        end

        private

        def now_in_milliseconds
          (Time.now.utc.to_f * 1000).to_i
        end

        def report?(prompt:)
          return true if Environment.send_monorail_events?
          ReportingConfigurationController.check_or_prompt_report_automatically(source: :usage, prompt: prompt)
        end

        def send_event(start_time, commands, args, err = nil)
          end_time = now_in_milliseconds
          headers = {
            'Content-Type': "application/json; charset=utf-8",
            'X-Monorail-Edge-Event-Created-At-Ms': start_time.to_s,
            'X-Monorail-Edge-Event-Sent-At-Ms': end_time.to_s,
          }
          begin
            Net::HTTP.start(
              ENDPOINT_URI.host,
              ENDPOINT_URI.port,
              # timeouts for opening a connection, reading, writing (in seconds)
              open_timeout: 0.2, read_timeout: 0.2, write_timeout: 0.2,
              use_ssl: ENDPOINT_URI.scheme == "https"
            ) do |http|
              payload = build_payload(start_time, end_time, commands, args, err)
              post = Net::HTTP::Post.new(ENDPOINT_URI.request_uri, headers)
              post.body = JSON.dump(payload)
              http.request(post)
            end
          rescue
            # silently fail on errors, fire-and-forget approach
          end
        end

        def build_payload(start_time, end_time, commands, args, err = nil)
          {
            schema_id: INVOCATIONS_SCHEMA,
            payload: {
              project_type: project_type_from_dir_or_cmd(commands[0]).to_s,
              command: commands.join(" "),
              args: args.join(" "),
              time_start: start_time,
              time_end: end_time,
              total_time: end_time - start_time,
              success: err.nil?,
              error_message: err,
              uname: RbConfig::CONFIG["host"],
              cli_version: ShopifyCLI::VERSION,
              ruby_version: RUBY_VERSION,
              is_employee: ShopifyCLI::Shopifolk.acting_as_shopify_organization?,
            }.tap do |payload|
              payload[:api_key] = metadata.delete(:api_key)
              payload[:partner_id] = metadata.delete(:organization_id) || ShopifyCLI::DB.get(:organization_id)
              if Project.has_current?
                project = Project.current(force_reload: true)
                payload[:api_key] = project.env&.api_key
                payload[:partner_id] = project.config["organization_id"]
              end
              payload[:metadata] = JSON.dump(metadata) unless metadata.empty?
            end,
          }
        end

        def project_type_from_dir_or_cmd(command)
          Project.current_project_type || (command unless ShopifyCLI::Commands.core_command?(command)) || nil
        end
      end
    end
  end
end
