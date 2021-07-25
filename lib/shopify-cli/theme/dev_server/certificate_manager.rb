# frozen_string_literal: true

require "openssl"

module ShopifyCli
  module Theme
    module DevServer
      class CertificateManager
        def initialize(ctx)
          @ctx = ctx
        end

        def private_key
          # private_key_file = OpenSSL::PKey::EC.new(::File.read('./localhost.shoesbycolin.com.key'))
          return @private_key if @private_key

          private_key_pem = ShopifyCli::DB.get(:tls_private_key)
          begin
            @private_key = OpenSSL::PKey::EC.new(private_key_pem) if private_key_pem
          rescue
            nil
          end
          return @private_key if @private_key

          @private_key = OpenSSL::PKey::EC.new("secp384r1")
          @private_key.generate_key
          ShopifyCli::DB.set(tls_private_key: @private_key.to_pem)
          @private_key
        end

        def intermediate_certificate
          # intermediate_file = OpenSSL::X509::Certificate.new(::File.read('./lets-encrypt-r3-cross-signed.pem'))
          nil
        end

        def find_or_create_certificate!(host = "localhost")
          # we generate one certificate per host
          certificate_cache_key = "#{host}_tls_certificate".to_sym
          certificate_pem = ShopifyCli::DB.get(certificate_cache_key)
          certificate = begin
                          OpenSSL::X509::Certificate.new(certificate_pem)
                        rescue
                          nil
                        end
          # TODO: should we check dh_compute_key is the same as the current private_key in cache?
          return certificate if certificate && certificate.not_after > Time.now.utc + 1 * 24 * 60 * 60

          certificate = sign_certificate!(host)
          ShopifyCli::DB.set(certificate_cache_key => certificate.to_pem)
          certificate
        end

        private

        def sign_certificate!(host)
          # certificate_file = OpenSSL::X509::Certificate.new(::File.read('./localhost.shoesbycolin.com.pem'))
          certificate = OpenSSL::X509::Certificate.new

          # technically we should be able to pass the private_key, but we want to ensure that the private_key doesn't
          # get bled when calling certificate.public_key, so we create a new ECDSA object and just copy the public_key
          public_ecdsa_key = OpenSSL::PKey::EC.new("secp384r1")
          key = private_key

          public_ecdsa_key.public_key = key.public_key

          certificate.public_key = public_ecdsa_key
          certificate.subject = OpenSSL::X509::Name.new([["CN", host]])
          certificate.version = 2
          certificate.serial = 0x0

          certificate.not_before = Time.now.utc
          certificate.not_after = Time.now.utc + 90 * 24 * 60 * 60

          ef = OpenSSL::X509::ExtensionFactory.new

          ef.subject_certificate = certificate
          ef.issuer_certificate = certificate

          # https://datatracker.ietf.org/doc/html/rfc5280#section-4.2.1.2
          # normally unique 160bit hash. For self signed we use =hash
          certificate.add_extension(ef.create_extension("subjectKeyIdentifier", "hash", false))

          # https://datatracker.ietf.org/doc/html/rfc5280#section-4.2.1.9
          # Are you (the subject of this certificate) a CA? YES
          certificate.add_extension(ef.create_extension("basicConstraints", "CA:TRUE", true))

          # https://datatracker.ietf.org/doc/html/rfc5280#section-4.2.1.12
          # KeyUsage=serverAuth is required for ios11+/macos10.15+ https://support.apple.com/en-us/HT210176
          certificate.add_extension(ef.create_extension("extendedKeyUsage", "serverAuth", false))

          # https://datatracker.ietf.org/doc/html/rfc5280#section-4.2.1.3
          # cRLSign: Subject public key is to verify signatures on revocation information, such as a CRL
          # digitalSignature: Certificate may be used to apply a digital signature
          # keyCertSign: Subject public key is used to verify signatures on certificates
          certificate.add_extension(ef.create_extension("keyUsage", "critical,cRLSign,digitalSignature,keyCertSign",
            false))

          # https://datatracker.ietf.org/doc/html/rfc5280#section-4.2.1.1
          # keyid - indicates that the subject key identifier is copied from the parent certificate.
          # keyid:always - indicates that the subject key identifier is copied from the parent certificate
          #   (and an error is returned if the copy fails.)
          # issuer - indicates that the issuer and serial number is copied from the issuer certificate if the keyid
          #   option fails or is not specified.
          # issuer:always - indicates that the issuer and serial number is always copied from the issuer certificate.
          certificate.add_extension(ef.create_extension("authorityKeyIdentifier", "keyid:always,issuer:always", false))

          # https://datatracker.ietf.org/doc/html/rfc5280#section-5.2.2
          certificate.add_extension(ef.create_extension("issuerAltName", "issuer:copy", false))
          certificate.add_extension(ef.create_extension("subjectAltName", "DNS:#{host},IP:127.0.0.1", false))

          certificate.sign(private_key, OpenSSL::Digest.new("SHA256"))
        end
      end
    end
  end
end
