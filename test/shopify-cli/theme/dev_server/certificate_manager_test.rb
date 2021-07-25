# frozen_string_literal: true
require "test_helper"
require "shopify-cli/theme/dev_server"

module ShopifyCli
  module Theme
    module DevServer
      class CertificateManagerTest < Minitest::Test
        def test_find_or_create_certificate!
          ctx = TestHelpers::FakeContext.new
          domain_name = "test.shopify.local"

          manager = CertificateManager.new(ctx)

          private_key_file = manager.private_key
          certificate_file = manager.find_or_create_certificate!(domain_name)

          expected_common_name = OpenSSL::X509::Name.new([["CN", domain_name]])

          assert(private_key_file.private?)
          assert_equal(expected_common_name, certificate_file.subject)
          assert_includes(certificate_file.extensions.map(&:to_s).flatten, "subjectAltName = DNS:test.shopify.local, IP Address:127.0.0.1")
        end
      end
    end
  end
end
