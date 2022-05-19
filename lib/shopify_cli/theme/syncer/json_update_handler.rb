# frozen_string_literal: true

require_relative "forms/apply_to_all"
require_relative "forms/select_update_strategy"

module ShopifyCLI
  module Theme
    class Syncer
      module JsonUpdateHandler
        def enqueue_json_updates(files)
          # Some files must be uploaded after the other ones
          delayed_files = [
            theme["config/settings_schema.json"],
            theme["config/settings_data.json"],
          ]

          # Update remote JSON files and delays `delayed_files` update
          files = files
            .select { |file| !ignore_file?(file) && file.exist? && checksums.file_has_changed?(file) }
            .sort_by { |file| delayed_files.include?(file) ? 1 : 0 }

          if overwrite_json?
            enqueue_updates(files)
          else
            # Handle conflicts when JSON files cannot be overwritten
            handle_update_conflicts(files)
          end
        end

        private

        def handle_update_conflicts(files)
          to_get = []
          to_delete = []
          to_update = []
          to_union_merge = []

          apply_to_all = Forms::ApplyToAll.new(@ctx, files.size)

          files.each do |file|
            update_strategy = apply_to_all.value || ask_update_strategy(file)
            apply_to_all.apply?(update_strategy)

            case update_strategy
            when :keep_remote
              if file_exist_remotely?(file)
                to_get << file
              else
                delete_locally(file)
              end
            when :keep_local
              to_update << file
            when :union_merge
              if file_exist_remotely?(file)
                to_union_merge << file
              else
                to_update << file
              end
            end
          end

          enqueue_get(to_get)
          enqueue_deletes(to_delete)
          enqueue_updates(to_update)
          enqueue_union_merges(to_union_merge)
        end

        def file_exist_remotely?(file)
          !checksums[file.relative_path].nil?
        end

        def delete_locally(file)
          ::File.delete(file.absolute_path)
        end

        def ask_update_strategy(file)
          Forms::SelectUpdateStrategy.ask(@ctx, [], file: file, exists_remotely: file_exist_remotely?(file)).strategy
        end
      end
    end
  end
end
