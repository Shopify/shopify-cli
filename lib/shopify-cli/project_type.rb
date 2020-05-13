module ShopifyCli
  class ProjectType
    class << self
      attr_accessor :project_type,
        :project_name,
        :project_creator_command_class
      attr_reader :hidden

      def repository
        @repository ||= []
      end
      alias_method :all_loaded, :repository

      def inherited(klass)
        repository << klass
        klass.project_type = @current_type
      end

      def load_type(current_type)
        filepath = File.join(ShopifyCli::ROOT, 'lib', 'project_types', current_type.to_s, 'cli.rb')
        return unless File.exist?(filepath)
        @current_type = current_type
        load(filepath)
        @current_type = nil
        for_app_type(current_type)
      end

      def load_all
        Dir.glob(File.join(ShopifyCli::ROOT, 'lib', 'project_types', '*', 'cli.rb')).map do |filepath|
          load_type(filepath.split(File::Separator)[-2])
        end
      end

      def for_app_type(type)
        repository.find { |k| k.project_type.to_s == type.to_s }
      end

      def project_filepath(path)
        File.join(ShopifyCli::PROJECT_TYPES_DIR, project_type.to_s, path)
      end

      def creator(name, command_const)
        @project_name = name
        @project_creator_command_class = command_const
        ShopifyCli::Commands::Create.subcommand(command_const, @project_type)
      end

      def create_command
        const_get(@project_creator_command_class)
      end

      def hidden_project_type
        @hidden = true
      end

      def register_command(const, cmd)
        Context.new.abort(
          Context.message('core.project_type.error.cannot_override_core', cmd, const)
        ) if Commands.core_command?(cmd)
        Commands.register(const, cmd)
      end

      def register_task(task, name)
        Task::Registry.add(const_get(task), name)
      end

      def register_messages(messages)
        # Make sure we don't attempt to register a file more than once as that will fail
        @registered_message_files = {} if @registered_message_files.nil?
        return if @registered_message_files.key?(@project_type)
        @registered_message_files[@project_type] = true

        Context.load_messages(messages)
      end
    end
  end
end
