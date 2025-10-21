# frozen_string_literal: true

module OAuthTestHelper
  def should_skip_oauth_tests?
    client_id = Rails.application.credentials.google&.dig(:client_id)
    return true if client_id.nil?
    return true if client_id.include?('test') || client_id.include?('fake')

    false
  end

  def skip_unless_real_oauth_credentials
    skip 'OAuth tests require real Google credentials' if should_skip_oauth_tests?
  end

  # rubocop:disable Metrics/MethodLength
  def stub_google_oauth_success(user_attrs = {})
    default_attrs = {
      uid: '123456789',
      email: 'test@example.com',
      name: 'Test User',
      first_name: 'Test',
      last_name: 'User',
    }

    attrs = default_attrs.merge(user_attrs)

    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: 'google_oauth2',
      uid: attrs[:uid],
      info: {
        email: attrs[:email],
        name: attrs[:name],
        first_name: attrs[:first_name],
        last_name: attrs[:last_name],
      },
      credentials: {
        token: 'mock_token',
        expires_at: 1.hour.from_now.to_i,
      },
    )
  end
  # rubocop:enable Metrics/MethodLength

  def stub_google_oauth_failure(failure_reason = :invalid_credentials)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = failure_reason
  end

  def reset_oauth_mocks
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth = {}
  end
end
