# rubocop:disable Lint/SelfAssignment
Rails.application.config.middleware.use OmniAuth::Builder do
  provider_config = provider_config
  provider :google_oauth2, *provider_config
end

OmniAuth.config.allowed_request_methods = %i[post]

def provider_config
  if Rails.env.production? || Rails.env.development?
    [Rails.application.credentials.google[:client_id], Rails.application.credentials.google[:client_secret], {}]
  else
    ['fake_client_id', 'fake_client_secret', {}]
  end
end
# rubocop:enable Lint/SelfAssignment
