# rubocop:disable Lint/SelfAssignment
Rails.application.config.middleware.use OmniAuth::Builder do
  # Use test credentials for test environment, real credentials for dev/prod
  if Rails.env.test?
    # Use fake credentials for test environment
    provider :google_oauth2, 'test_client_id', 'test_client_secret', {}
  else
    # Use real credentials from Rails credentials for dev/prod
    provider :google_oauth2, 
             Rails.application.credentials.google[:client_id], 
             Rails.application.credentials.google[:client_secret], 
             {}
  end
end

OmniAuth.config.allowed_request_methods = %i[post]
# rubocop:enable Lint/SelfAssignment