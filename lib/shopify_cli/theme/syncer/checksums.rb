# frozen_string_literal: true

module ShopifyCLI
  module Theme
    class Syncer
      class Checksums
        def initialize(theme)
          @theme = theme
          @checksum_by_key = {}

          # Mutex used to coordinate changes in the checksums (shared accross `Syncer` threads)
          @checksums_mutex = Mutex.new
        end

        def has?(file)
          checksum_by_key.key?(to_key(file))
        end

        def file_has_changed?(file)
          file.checksum != checksum_by_key[file.relative_path]
        end

        def delete(file)
          checksums_mutex.synchronize do
            checksum_by_key.delete(to_key(file))
          end
        end

        def keys
          checksum_by_key.keys
        end

        def [](key)
          checksum_by_key[key]
        end

        def []=(key, value)
          checksums_mutex.synchronize do
            checksum_by_key[key] = value
          end
        end

        # Generate .liquid asset files are reported twice in checksum:
        # once of generated, once for .liquid. We only keep the .liquid, that's the one we have
        # on disk.
        def reject_duplicated_checksums!
          checksums_mutex.synchronize do
            checksum_by_key.reject! { |key, _| checksum_by_key.key?("#{key}.liquid") }
          end
        end

        private

        def to_key(file)
          theme[file].relative_path
        end

        # Private getters only used in unit tests

        attr_reader :checksum_by_key
        attr_reader :theme
        attr_reader :checksums_mutex
      end
    end
  end
end
