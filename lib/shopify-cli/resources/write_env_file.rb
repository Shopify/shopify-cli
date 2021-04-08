# frozen_string_literal: true

module ShopifyCli
  module Resources
    class WriteEnvFile
      include MethodObject

      property! :path, accepts: ->(path) { File.directory?(File.dirname(path)) }, converts: :to_s
      property! :ctx

      def call(variables)
        Result
          .wrap(variables)
          .then(&method(:validate))
          .then(&method(:serialize))
          .then(&method(:write))
      end

      private

      def validate(variables)
        return variables if variables.all? { |name, value| name.is_a?(String) && value.is_a?(String) }
        raise ArgumentError, "Expected variables to be Hash<String, String>"
      end

      def serialize(variables)
        serialized_variables = variables
          .map { |key, value| [key, value].join("=") }
          .join("\n")

        serialized_variables + "\n"
      end

      def write(serialized_variables)
        show_progess do
          ctx.write(path, serialized_variables)
        end
      end

      def show_progess(&task)
        CLI::UI::SpinGroup.new.tap do |spin_group|
          result = nil

          spin_group.add(header) do |spinner|
            ctx.print_task(saving)
            result = task.call
            spinner.update_title(saved)
          end
          spin_group.wait

          result
        end
      end

      def header
        ctx.message("core.env_file.saving_header", File.basename(path))
      end

      def saving
        ctx.message("core.env_file.saving", File.basename(path))
      end

      def saved
        ctx.message("core.env_file.saved", File.basename(path))
      end
    end
  end
end
