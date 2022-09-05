# frozen_string_literal: true

require "openssl"

module ShopifyCLI
  module Theme
    class DevServer
      class CertificateManager
        attr_reader :ctx, :domain_name, :certificate, :private_key

        ISSUER_EXTENSIONS = [
          ["subjectKeyIdentifier", "hash", false],
          ["authorityKeyIdentifier", "keyid:always", false],
        ]

        def initialize(ctx, domain_name)
          @ctx = ctx
          @domain_name = domain_name
        end

        def find_or_create_certificates!
          @private_key = if (private_key_pem = ShopifyCLI::DB.get(:ssl_private_key))
            OpenSSL::PKey::RSA.new(private_key_pem)
          else
            OpenSSL::PKey::RSA.new(2048)
          end

          @certificate = if (certificate_pem = ShopifyCLI::DB.get(:ssl_certificate))
            OpenSSL::X509::Certificate.new(certificate_pem)
          else
            x509_certificate = build_x509_certificate

            sign_certificate!(x509_certificate)

            x509_certificate
          end

          ShopifyCLI::DB.set(ssl_certificate: certificate.to_pem)
          ShopifyCLI::DB.set(ssl_private_key: private_key.to_pem)
        end

        private

        def build_x509_certificate
          certificate = OpenSSL::X509::Certificate.new

          certificate.public_key = private_key.public_key
          certificate.subject = subject
          certificate.version = 2
          certificate.serial = 0x0

          certificate.not_before = Time.now.utc
          certificate.not_after = Time.now.utc + 365 * 24 * 60 * 60

          certificate
        end

        def sign_certificate!(certificate)
          ef = OpenSSL::X509::ExtensionFactory.new

          ef.subject_certificate = certificate
          ef.issuer_certificate = certificate

          ISSUER_EXTENSIONS.each do |args|
            certificate.add_extension(ef.create_extension(*args))
          end

          certificate.add_extension(ef.create_extension("subjectAltName", "DNS:#{@domain_name}", false))

          certificate.sign(private_key, OpenSSL::Digest.new("SHA256"))
        end

        def subject
          OpenSSL::X509::Name.parse("/CN=#{@domain_name}/")
        end
      end
    end
  end
end
