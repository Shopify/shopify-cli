# typed: ignore
# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/dev_server"

module ShopifyCLI
  module Theme
    module DevServer
      class CertificateManagerTest < Minitest::Test
        def test_find_or_create_certificates!
          ctx = TestHelpers::FakeContext.new
          domain_name = "test.shopify.local"

          manager = CertificateManager.new(ctx, domain_name)

          manager.find_or_create_certificates!

          private_key_file = OpenSSL::PKey::RSA.new(manager.private_key)
          certificate_file = OpenSSL::X509::Certificate.new(manager.certificate)

          expected_common_name = OpenSSL::X509::Name.new([["CN", domain_name]])

          assert(private_key_file.private?)
          assert_equal(expected_common_name, certificate_file.subject)
          assert_includes(certificate_file.extensions.map(&:to_s).flatten, "subjectAltName = DNS:test.shopify.local")
        end
      end
    end
  end
end
