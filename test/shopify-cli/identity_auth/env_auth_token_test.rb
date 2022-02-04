require "test_helper"

module ShopifyCLI
  class IdentityAuth
    class EnvAuthTokenTest < MiniTest::Test
      def test_partners_token_present
        # Given
        Environment.expects(:auth_token).returns("token")

        # When
        got = EnvAuthToken.partners_token_present?

        # Then
        assert got
      end

      def test_exchanged_partners_token
        # Given
        EnvAuthToken.stubs(:exchanged_partners_token=).with do |token|
          token.token == "access_token"
        end
        EnvAuthToken.stubs(:exchanged_partners_token).returns(nil)
        Environment.stubs(:auth_token).returns("subject_token")

        # When
        got = EnvAuthToken.fetch_exchanged_partners_token do |subject_token|
          assert_equal "subject_token", subject_token
          { "access_token" => "access_token", "expires_in" => 100 }
        end

        # Then
        assert_equal "access_token", got
      end

      def test_exchanged_partners_returns_an_existing_token_if_it_hasnt_expired
        # Given
        expires_at = Time.now.to_i + 3000
        EnvAuthToken
          .stubs(:exchanged_partners_token)
          .returns(EnvAuthToken::Token.new(token: "existing", expires_at: expires_at))

        # When
        got = EnvAuthToken.fetch_exchanged_partners_token do |_subject_token|
          { "access_token" => "access_token", "expires_in" => 100 }
        end

        # Then
        assert_equal "existing", got
      end

      def test_exchanged_partners_token_exchanges_the_token_if_the_existing_has_expired
        # Given
        expires_at = Time.now.to_i - 3000
        EnvAuthToken.expects(:exchanged_partners_token=).with do |token|
          token.token == "access_token"
        end
        EnvAuthToken
          .stubs(:exchanged_partners_token)
          .returns(EnvAuthToken::Token.new(token: "existing", expires_at: expires_at))
        Environment.stubs(:auth_token).returns("subject_token")

        # When
        got = EnvAuthToken.fetch_exchanged_partners_token do |subject_token|
          assert_equal "subject_token", subject_token
          { "access_token" => "access_token", "expires_in" => 100 }
        end

        # Then
        assert_equal "access_token", got
      end
    end
  end
end
