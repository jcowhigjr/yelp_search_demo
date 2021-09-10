Rails.application.config.middleware.use OmniAuth::Builder do
  # provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET']
  provider :google_oauth2, Rails.application.credentials.google[:client_id],
           Rails.application.credentials.google[:client_secret], {}
end
OmniAuth.config.allowed_request_methods = %i[post]

