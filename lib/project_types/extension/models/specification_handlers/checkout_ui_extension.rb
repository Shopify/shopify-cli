# frozen_string_literal: true

module Extension
  module Models
    module SpecificationHandlers
      class CheckoutUiExtension < Default
        L10N_ERROR_PREFIX = "core.extension.push.checkout_ui_extension.localization.error"
        L10N_FILE_SIZE_LIMIT = 16 * 1024 # 16kb
        L10N_BUNDLE_SIZE_LIMIT = 256 * 1024 # 256kb
        LOCALE_CODE_FORMAT = %r{
          \A
          (?<language>[a-zA-Z]{2,3}) # Language tag
          (?:
           -
           (?<region>[a-zA-Z]{2}) # Optional region subtag
          )?
          \z}x
        PERMITTED_CONFIG_KEYS = [:extension_points, :metafields, :name, :capabilities]

        def config(context)
          {
            **Features::ArgoConfig.parse_yaml(context, PERMITTED_CONFIG_KEYS),
            **argo.config(context, include_renderer_version: false),
            **localization(context),
          }
        end

        def supplies_resource_url?
          true
        end

        def build_resource_url(context:, shop:)
          product = Tasks::GetProduct.call(context, shop)
          return unless product
          format("/cart/%<variant_id>d:%<quantity>d", variant_id: product.variant_id, quantity: 1)
        end

        private

        def localization(context)
          Dir.chdir(context.root) do
            locale_filenames = Dir["locales/*"].select { |filename| valid_l10n_file?(filename) }
            # Localization is optional
            return {} if locale_filenames.empty?

            validate_no_duplicate_locale(locale_filenames)
            validate_total_size(locale_filenames)
            default_locale = single_default_locale(locale_filenames)

            locale_filenames.map do |filename|
              locale = basename_for_locale_filename(filename)
              [locale.to_sym, read_locale_file(filename)]
            end
              .yield_self do |encoded_files_by_locale|
              {
                localization: {
                  default_locale: default_locale,
                  translations: encoded_files_by_locale.to_h,
                },
              }
            end
          end
        end

        def read_locale_file(filename)
          content = File.read(filename, mode: "rt", encoding: "bom|utf-8").strip
          raise_invalid_encoding_error(filename) unless content.valid_encoding?
          Base64.strict_encode64(content)
        rescue ArgumentError
          raise_invalid_encoding_error(filename)
        end

        def validate_no_duplicate_locale(locale_filenames)
          duplicate_locale = locale_filenames
            .map { |filename| basename_for_locale_filename(filename.downcase) }
            .group_by { |locale| locale }
            .detect { |_k, v| v.size > 1 }
            &.first
          raise(
            ShopifyCLI::Abort,
            ShopifyCLI::Context.message("#{L10N_ERROR_PREFIX}.duplicate_locale_code", duplicate_locale)
          ) unless duplicate_locale.nil?
        end

        def validate_total_size(locale_filenames)
          total_size = locale_filenames.sum { |filename| File.size(filename) }
          if total_size > L10N_BUNDLE_SIZE_LIMIT
            raise(
              ShopifyCLI::Abort,
              ShopifyCLI::Context.message(
                "#{L10N_ERROR_PREFIX}.bundle_too_large",
                CLI::Kit::Util.to_filesize(L10N_BUNDLE_SIZE_LIMIT)
              )
            )
          end
        end

        def single_default_locale(locale_filenames)
          default_locale_matches = locale_filenames.grep(/default/)
          if default_locale_matches.size != 1
            raise(ShopifyCLI::Abort, ShopifyCLI::Context.message("#{L10N_ERROR_PREFIX}.single_default_locale"))
          end
          basename_for_locale_filename(default_locale_matches.first)
        end

        def valid_l10n_file?(filename)
          return false unless File.file?(filename)
          return false unless File.dirname(filename) == "locales"

          validate_file_extension(filename)
          validate_file_locale_code(filename)
          validate_file_size(filename)
          validate_file_not_empty(filename)

          true
        end

        def validate_file_extension(filename)
          if File.extname(filename) != ".json"
            raise(
              ShopifyCLI::Abort, ShopifyCLI::Context.message("#{L10N_ERROR_PREFIX}.invalid_file_extension", filename)
            )
          end
        end

        def validate_file_locale_code(filename)
          unless valid_locale_code?(basename_for_locale_filename(filename))
            raise(
              ShopifyCLI::Abort, ShopifyCLI::Context.message("#{L10N_ERROR_PREFIX}.invalid_locale_code", filename)
            )
          end
        end

        def validate_file_size(filename)
          if File.size(filename) > L10N_FILE_SIZE_LIMIT
            raise(
              ShopifyCLI::Abort,
              ShopifyCLI::Context.message(
                "#{L10N_ERROR_PREFIX}.file_too_large",
                filename,
                CLI::Kit::Util.to_filesize(L10N_FILE_SIZE_LIMIT)
              )
            )
          end
        end

        def validate_file_not_empty(filename)
          if File.zero?(filename)
            raise(ShopifyCLI::Abort, ShopifyCLI::Context.message("#{L10N_ERROR_PREFIX}.file_empty", filename))
          end
        end

        def valid_locale_code?(locale_code)
          LOCALE_CODE_FORMAT.match?(locale_code)
        end

        def basename_for_locale_filename(filename)
          File.basename(File.basename(filename, ".json"), ".default")
        end

        def raise_invalid_encoding_error(filename)
          raise(
            ShopifyCLI::Abort,
            ShopifyCLI::Context.message("#{L10N_ERROR_PREFIX}.invalid_file_encoding", filename)
          )
        end
      end
    end
  end
end
