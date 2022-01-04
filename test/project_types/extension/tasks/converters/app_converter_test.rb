# typed: ignore
# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Tasks
    module Converters
      class AppConverterTest < MiniTest::Test
        include TestHelpers::FakeUI

        def setup
          super
          ShopifyCLI::ProjectType.load_type(:extension)

          @api_key = "fake_key"
          @secret = "fake_secret"
          @title = "Fake Title"
          @organization_name = "Organization One"
        end

        def test_from_hash_returns_nil_if_the_hash_is_nil
          assert_nil(Converters::AppConverter.from_hash(nil))
        end

        def test_from_hash_parses_app_from_a_hash
          hash = {
            Converters::AppConverter::API_KEY_FIELD => @api_key,
            Converters::AppConverter::TITLE_FIELD => @title,
            Converters::AppConverter::API_SECRET_KEYS_FIELD => [
              { Converters::AppConverter::API_SECRET_FIELD => @secret },
            ],
          }

          parsed_app = Converters::AppConverter.from_hash(hash)

          assert_kind_of(Models::App, parsed_app)
          assert_equal @api_key, parsed_app.api_key
          assert_equal @secret, parsed_app.secret
          assert_equal @title, parsed_app.title
          assert_nil(parsed_app.business_name)
        end

        def test_from_hash_parses_organization_name_if_organization_is_provided
          app_hash = {
            Converters::AppConverter::API_KEY_FIELD => @api_key,
            Converters::AppConverter::TITLE_FIELD => @title,
            Converters::AppConverter::API_SECRET_KEYS_FIELD => [
              { Converters::AppConverter::API_SECRET_FIELD => @secret },
            ],
          }

          organization_hash = {
            Converters::AppConverter::ORGANIZATION_NAME_FIELD => @organization_name,
          }

          parsed_app = Converters::AppConverter.from_hash(app_hash, organization_hash)

          assert_kind_of(Models::App, parsed_app)
          assert_equal @api_key, parsed_app.api_key
          assert_equal @secret, parsed_app.secret
          assert_equal @title, parsed_app.title
          assert_equal @organization_name, parsed_app.business_name
        end
      end
    end
  end
end
