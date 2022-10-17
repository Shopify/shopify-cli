# frozen_string_literal: true

require_relative "forms/apply_to_all"
require_relative "forms/select_delete_strategy"

module ShopifyCLI
  module Theme
    class Syncer
      class Uploader
        module JsonDeleteHandler
          def enqueue_json_deletes(files)
            return enqueue_deletes(files) if overwrite_json?

            # Handle conflicts when JSON files cannot be overwritten
            handle_delete_conflicts(files)
          end

          private

          def handle_delete_conflicts(files)
            to_delete = []
            to_get = []

            apply_to_all = Forms::ApplyToAll.new(ctx, files.size)

            files.each do |file|
              delete_strategy = apply_to_all.value || ask_delete_strategy(file)
              apply_to_all.apply?(delete_strategy)

              case delete_strategy
              when :delete
                to_delete << file
              when :restore
                to_get << file
              end
            end

            enqueue_deletes(to_delete)
            enqueue_get(to_get)
          end

          def ask_delete_strategy(file)
            Forms::SelectDeleteStrategy.ask(ctx, [], file: file).strategy
          end
        end
      end
    end
  end
end
